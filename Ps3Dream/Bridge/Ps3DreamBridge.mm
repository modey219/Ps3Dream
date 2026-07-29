// Ps3Dream iOS - Core Emulator Bridge Implementation
// This is the heart of the iOS port: replaces Android JNI with direct C++ calls

#include "Ps3DreamBridge.h"
#include "../Platform/ios_window.h"
#include "../Platform/ios_log.h"
#include "../JIT/ios_jit.h"
#include "../MoltenVK/ios_mvk.h"

// RPCS3 headers
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
#pragma clang diagnostic ignored "-Wold-style-cast"
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#pragma clang diagnostic ignored "-Wsign-compare"

#include "Emu/System.h"
#include "Emu/system_config.h"
#include "Emu/system_utils.hpp"
#include "Emu/IdManager.h"
#include "Emu/VFS.h"
#include "Emu/vfs_config.h"
#include "Emu/system_progress.hpp"

#include "Emu/Cell/PPUThread.h"
#include "Emu/Cell/SPUThread.h"
#include "Emu/CPU/CPUThread.h"

#include "Emu/Io/PadHandler.h"
#include "Emu/Io/Null/NullPadHandler.h"
#include "Emu/Io/Null/NullKeyboardHandler.h"
#include "Emu/Io/Null/NullMouseHandler.h"
#include "Emu/Io/Null/null_music_handler.h"
#include "Emu/Io/Null/null_camera_handler.h"

#include "Emu/Audio/Null/NullAudioBackend.h"
#include "Emu/Audio/Cubeb/CubebBackend.h"

#include "Emu/RSX/VK/VKGSRender.h"
#include "Emu/RSX/GSFrameBase.h"
#include "Emu/RSX/Overlays/HomeMenu/overlay_home_menu.h"
#include "Emu/RSX/Overlays/overlay_message.h"
#include "Emu/RSX/Overlays/overlay_save_dialog.h"
#include "Emu/RSX/Overlays/overlay_trophy_notification.h"
#include "Emu/RSX/Overlays/overlay_fonts.h"

#include "Input/pad_thread.h"
#include "Input/product_info.h"

#include "Emu/Cell/Modules/cellSaveData.h"
#include "Emu/Cell/Modules/sceNpTrophy.h"
#include "Emu/Cell/Modules/cellSysutil.h"
#include "Emu/Cell/Modules/cellMusic.h"
#include "Emu/Cell/Modules/cellMsgDialog.h"
#include "Emu/Cell/Modules/cellOskDialog.h"
#include "Emu/Cell/Modules/sceNp.h"

#include "Emu/Cell/lv2/sys_usbd.h"

#include "Crypto/unpkg.h"
#include "Crypto/unself.h"

#include "Loader/PUP.h"
#include "Loader/TAR.h"
#include "Loader/PSF.h"
#include "Loader/iso.h"

#include "Utilities/File.h"
#include "Utilities/Thread.h"
#include "util/sysinfo.hpp"
#include "util/serialization_ext.hpp"
#include "util/logs.hpp"
#include "util/video_provider.h"

#include "rpcs3_version.h"

#include "yaml-cpp/yaml.h"

#pragma clang diagnostic pop

// ==================== Log Channel ====================
LOG_CHANNEL(ps3dream_log, "PS3DREAM");

// ==================== Global State ====================
static std::atomic<int> g_status{Ps3DreamStatusUnknown};
static std::mutex g_emu_mutex;
static std::condition_variable g_emu_cond;
static std::string g_boot_path;
static int g_boot_fd = -1;
static std::string g_boot_uri;
static int g_boot_type = 0;

// Callbacks
static Ps3DreamLogCallback g_log_callback = nullptr;
static Ps3DreamStatusCallback g_status_callback = nullptr;
static Ps3DreamFrameCallback g_frame_callback = nullptr;

static void notify_status(int status) {
    g_status.store(status);
    if (g_status_callback) g_status_callback(status);
}

// ==================== iOS GS Frame ====================
// Replaces android_gs_frame from aps3e_rp3_impl.h

class ios_gs_frame : public GSFrameBase {
public:
    ios_gs_frame() {
        g_fxo->need<utils::video_provider>();
    }
    ~ios_gs_frame() override = default;

    void close() override {}
    void reset() override {}
    bool shown() override { return false; }
    void hide() override {}
    void show() override {}
    void toggle_fullscreen() override {}

    void delete_context(draw_context_t ctx) override {}
    draw_context_t make_context() override { return nullptr; }
    void set_current(draw_context_t ctx) override {}
    void flip(draw_context_t ctx, bool skip_frame = false) override {}
    int client_width() override { return g_ios_window_width; }
    int client_height() override { return g_ios_window_height; }
    f64 client_display_rate() override { return 60.0; }
    bool has_alpha() override { return true; }

    display_handle_t handle() const override {
        return reinterpret_cast<void*>(g_ios_window);
    }

    bool can_consume_frame() const override {
        utils::video_provider& vp = g_fxo->get<utils::video_provider>();
        return vp.can_consume_frame();
    }

    void present_frame(std::vector<u8>&& data, u32 pitch, u32 width, u32 height, bool is_bgra) const override {
        utils::video_provider& vp = g_fxo->get<utils::video_provider>();
        vp.present_frame(std::move(data), pitch, width, height, is_bgra);
    }

    void take_screenshot(std::vector<u8>&& data, u32 w, u32 h, bool is_bgra) override {}
    void update_title(double fps) override {}
};

// ==================== iOS Virtual Pad Handler ====================
// Simplified version of AndroidVirtualPadHandler

class ios_virtual_pad_handler final : public PadHandlerBase {
public:
    bool Init() override { return true; }
    void init_config(cfg_pad* cfg) override {}
    std::vector<pad_list_entry> list_devices() override { return {}; }
    connection get_next_button_press(const std::string&, const pad_callback&, const pad_fail_callback&, gui_call_type, const std::vector<std::string>&) override { return connection::connected; }
    bool bindPadToDevice(std::shared_ptr<Pad> pad) override { return true; }
    void process() override {}

    void Key(u32 code, bool pressed, u16 value = 255) {
        std::lock_guard lock(pad_mutex);
        for (auto& binding : m_bindings) {
            for (auto& btn : binding.pad->m_buttons) {
                if (btn.m_outKeyCode == code) {
                    btn.m_pressed = pressed;
                    btn.m_value = pressed ? value : 0;
                }
            }
        }
    }

    mutable std::mutex pad_mutex;
};

// ==================== iOS Music Handler ====================
class ios_music_handler : public music_handler_base {
public:
    void stop() override { set_state(0x101); }           // CELL_MUSIC_PB_STATUS_STOP
    void pause() override { set_state(0x102); }          // CELL_MUSIC_PB_STATUS_PAUSE
    void play(const std::string& path, bool automatic) override { set_state(0x100, automatic); }  // CELL_MUSIC_PB_STATUS_PLAY
    void fast_forward(const std::string& path) override { set_state(0x104); }    // CELL_MUSIC_PB_STATUS_FASTFORWARD
    void fast_reverse(const std::string& path) override { set_state(0x105); }    // CELL_MUSIC_PB_STATUS_FASTREVERSE
    void set_volume(f32 volume) override {}
    f32 get_volume() const override { return 0; }
};

// ==================== Dialog Stubs ====================
// Simplified dialog implementations (same as Android version)

class ios_save_dialog : public SaveDialogBase {
public:
    s32 ShowSaveDataList(const std::string& base_dir, std::vector<SaveDataEntry>& entries, s32 focused, u32 op, vm::ptr<CellSaveDataListSet> listSet, bool enable_overlay) override {
        const bool use_end = sysutil_send_system_cmd(CELL_SYSUTIL_DRAWING_BEGIN, 0) >= 0;
        if (auto manager = g_fxo->try_get<rsx::overlays::display_manager>()) {
            const s32 result = manager->create<rsx::overlays::save_dialog>()->show(base_dir, entries, focused, op, listSet, enable_overlay);
            if (result != rsx::overlays::user_interface::selection_code::error) {
                if (use_end) sysutil_send_system_cmd(CELL_SYSUTIL_DRAWING_END, 0);
                return result;
            }
        }
        if (use_end) sysutil_send_system_cmd(CELL_SYSUTIL_DRAWING_END, 0);
        return -2;
    }
};

class ios_trophy_notification : public TrophyNotificationBase {
public:
    s32 ShowTrophyNotification(const SceNpTrophyDetails& trophy, const std::vector<uchar>& icon) override {
        if (auto manager = g_fxo->try_get<rsx::overlays::display_manager>()) {
            auto popup = std::make_shared<rsx::overlays::trophy_notification>();
            return manager->add(popup, false)->show(trophy, icon);
        }
        return 0;
    }
};

class ios_msg_dialog : public MsgDialogBase {
public:
    void Create(const std::string& msg, const std::string& title) override {
        state = MsgDialogState::Open;
        Close(true);
        if (type.button_type.unshifted() == CELL_MSGDIALOG_TYPE_BUTTON_TYPE_YESNO)
            on_close(CELL_MSGDIALOG_BUTTON_YES);
        else if (type.button_type.unshifted() == CELL_MSGDIALOG_TYPE_BUTTON_TYPE_OK)
            on_close(CELL_MSGDIALOG_BUTTON_OK);
    }
    void Close(bool) override {}
    void SetMsg(const std::string&) override {}
    void ProgressBarSetMsg(u32, const std::string&) override {}
    void ProgressBarReset(u32) override {}
    void ProgressBarInc(u32, u32) override {}
    void ProgressBarSetValue(u32, u32) override {}
    void ProgressBarSetLimit(u32, u32) override {}
};

class ios_osk_dialog : public OskDialogBase {
public:
    void Create(const osk_params& params) override {
        state = OskDialogState::Open;
        on_osk_close(CELL_OSKDIALOG_CLOSE_CANCEL);
    }
    void Clear(bool) override {}
    void Insert(const std::u16string&) override {}
    void SetText(const std::u16string&) override {}
    void Close(s32) override {}
};

class ios_send_msg_dialog : public SendMessageDialogBase {
public:
    error_code Exec(message_data&, std::set<std::string>&) override { return CELL_CANCEL; }
    void callback_handler(rpcn::NotificationType, const std::string&, bool) override {}
};

class ios_recv_msg_dialog : public RecvMessageDialogBase {
public:
    error_code Exec(SceNpBasicMessageMainType, SceNpBasicMessageRecvOptions, SceNpBasicMessageRecvAction&, u64&) override { return CELL_CANCEL; }
    void callback_handler(const shared_ptr<std::pair<std::string, message_data>>, u64) override {}
};

// ==================== Emulator Callbacks ====================

static EmuCallbacks create_ios_emu_cb() {
    EmuCallbacks cb{};

    cb.on_run = [](bool) {};
    cb.on_pause = []() {};
    cb.on_resume = []() {};
    cb.update_emu_settings = []() {};
    cb.save_emu_settings = []() {};

    cb.init_kb_handler = []() {
        g_fxo->init<KeyboardHandlerBase, NullKeyboardHandler>(Emu.DeserialManager());
    };

    cb.init_mouse_handler = []() {
        g_fxo->init<MouseHandlerBase, NullMouseHandler>(Emu.DeserialManager());
    };

    cb.init_pad_handler = [](std::string_view title_id) {
        ensure(g_fxo->init<named_thread<pad_thread>>(nullptr, nullptr, title_id));
    };

    cb.get_audio = []() -> std::shared_ptr<AudioBackend> {
        return std::make_shared<NullAudioBackend>();
    };

    cb.get_audio_enumerator = [](u64 renderer) -> std::shared_ptr<audio_device_enumerator> {
        return nullptr;
    };

    cb.get_image_info = [](const std::string&, std::string&, s32&, s32&, s32&) -> bool { return false; };
    cb.get_scaled_image = [](const std::string&, s32, s32, s32&, s32&, u8*, bool) -> bool { return false; };

    cb.resolve_path = [](std::string_view sv) {
        return std::string{sv};
    };

    cb.on_install_pkgs = [](const std::vector<std::string>& pkgs) -> bool {
        for (const auto& pkg : pkgs) {
            std::deque<package_reader> readers;
            readers.emplace_back(pkg);
            std::deque<std::string> bootable_paths;
            auto result = package_reader::extract_data(readers, bootable_paths);
            if (result.error != package_install_result::error_type::no_error) return false;
        }
        return true;
    };

    cb.try_to_quit = [](bool, std::function<void()> on_exit) -> bool {
        if (on_exit) on_exit();
        return true;
    };

    cb.call_from_main_thread = [](std::function<void()> func, atomic_t<u32>* wake_up) {
        func();
        if (wake_up) { *wake_up = true; wake_up->notify_one(); }
    };

    cb.init_gs_render = [](utils::serial* ar) {
        switch (g_cfg.video.renderer.get()) {
            case video_renderer::vulkan:
                g_fxo->init<rsx::thread, named_thread<VKGSRender>>(ar);
                break;
            default: break;
        }
    };

    cb.get_camera_handler = []() -> std::shared_ptr<camera_handler_base> {
        return std::make_shared<null_camera_handler>();
    };

    cb.get_music_handler = []() -> std::shared_ptr<music_handler_base> {
        return std::make_shared<ios_music_handler>();
    };

    cb.get_msg_dialog = []() -> std::shared_ptr<MsgDialogBase> { return std::make_shared<ios_msg_dialog>(); };
    cb.get_osk_dialog = []() -> std::shared_ptr<OskDialogBase> { return std::make_shared<ios_osk_dialog>(); };
    cb.get_save_dialog = []() -> std::unique_ptr<SaveDialogBase> { return std::make_unique<ios_save_dialog>(); };
    cb.get_trophy_notification_dialog = []() -> std::unique_ptr<TrophyNotificationBase> { return std::make_unique<ios_trophy_notification>(); };
    cb.get_sendmessage_dialog = []() -> std::shared_ptr<SendMessageDialogBase> { return std::make_shared<ios_send_msg_dialog>(); };
    cb.get_recvmessage_dialog = []() -> std::shared_ptr<RecvMessageDialogBase> { return std::make_shared<ios_recv_msg_dialog>(); };

    cb.on_stop = []() { notify_status(Ps3DreamStatusStopped); };
    cb.on_ready = []() {};
    cb.on_emulation_stop_no_response = [](std::shared_ptr<atomic_t<bool>>, int) {};
    cb.on_save_state_progress = [](std::shared_ptr<atomic_t<bool>>, stx::shared_ptr<utils::serial>, stx::atomic_ptr<std::string>*, std::shared_ptr<void>) {};
    cb.enable_disc_eject = [](bool) {};
    cb.enable_disc_insert = [](bool) {};
    cb.on_missing_fw = []() {};
    cb.handle_taskbar_progress = [](s32, s32) {};

    cb.get_localized_string = [](localized_string_id id, const char* args) -> std::string {
        // Simplified localization - return English defaults
        return std::string(args ? args : "");
    };

    cb.play_sound = [](const std::string&, std::optional<float>) {};
    cb.add_breakpoint = [](u32) {};

    return cb;
}

// ==================== Emulator Init ====================

static void ios_emu_init() {
    // Enable JIT
    ios_enable_jit();

    // Initialize MoltenVK
    ios_mvk_initialize();

    // Set resource limits
    struct rlimit rlim;
    rlim.rlim_cur = 4096;
    rlim.rlim_max = 4096;
    setrlimit(RLIMIT_NOFILE, &rlim);

    rlim.rlim_cur = RLIM_INFINITY;
    rlim.rlim_max = RLIM_INFINITY;
    setrlimit(RLIMIT_MEMLOCK, &rlim);

    // Create callbacks
    auto callbacks = create_ios_emu_cb();

    // Set GS frame factory
    callbacks.get_gs_frame = []() -> std::unique_ptr<GSFrameBase> {
        return std::make_unique<ios_gs_frame>();
    };

    Emu.SetCallbacks(std::move(callbacks));
    Emu.SetHasGui(true);
    Emu.Init();
}

// ==================== Emulation Thread ====================

static std::thread s_emu_thread;

static void ios_main_thr() {
    notify_status(Ps3DreamStatusRunning);

    ios_emu_init();

    Emu.SetForceBoot(true);
    game_boot_result result;

    if (g_boot_type == 1) {
        result = Emu.BootGame(g_boot_path, {}, true);
    } else if (g_boot_fd >= 0) {
        result = Emu.BootGame(g_boot_path, {}, true);
    } else if (!g_boot_uri.empty()) {
        result = Emu.BootGame(g_boot_uri, {}, true);
    }

    if (result != game_boot_result::no_errors) {
        LOGE("Boot failed: %d", (int)result);
        notify_status(Ps3DreamStatusStopped);
        return;
    }

    // Main loop
    while (true) {
        int status = g_status.load();
        if (status == Ps3DreamStatusRequestPause) {
            std::lock_guard lock(g_emu_mutex);
            Emu.Pause(false, false);
            g_status.store(Ps3DreamStatusPaused);
            g_emu_cond.notify_all();
        } else if (status == Ps3DreamStatusRequestResume) {
            std::lock_guard lock(g_emu_mutex);
            Emu.Resume();
            g_status.store(Ps3DreamStatusRunning);
            g_emu_cond.notify_all();
        } else if (status == Ps3DreamStatusRequestStop) {
            std::lock_guard lock(g_emu_mutex);
            Emu.Kill();
            g_status.store(Ps3DreamStatusStopped);
            g_emu_cond.notify_all();
            break;
        }
        usleep(100);
    }
}

// ==================== C API Implementation ====================

void ps3dream_init(void) {
    g_status.store(Ps3DreamStatusUnknown);
}

bool ps3dream_boot_game(const char* game_path) {
    g_boot_path = game_path;
    g_boot_type = 1;
    return true;
}

bool ps3dream_boot_game_fd(int fd) {
    g_boot_fd = fd;
    g_boot_type = 2;
    return true;
}

bool ps3dream_boot_game_uri(const char* uri) {
    g_boot_uri = uri;
    g_boot_type = 3;
    return true;
}

void ps3dream_boot(void) {
    if (s_emu_thread.joinable()) {
        ps3dream_quit();
        usleep(100000);
    }
    s_emu_thread = std::thread(ios_main_thr);
    s_emu_thread.detach();
}

void ps3dream_pause(void) {
    if (g_status.load() == Ps3DreamStatusRunning) {
        std::unique_lock lock(g_emu_mutex);
        g_status.store(Ps3DreamStatusRequestPause);
        g_emu_cond.wait(lock, []{ return g_status.load() == Ps3DreamStatusPaused; });
    }
}

void ps3dream_resume(void) {
    if (g_status.load() == Ps3DreamStatusPaused) {
        std::unique_lock lock(g_emu_mutex);
        g_status.store(Ps3DreamStatusRequestResume);
        g_emu_cond.wait(lock, []{ return g_status.load() == Ps3DreamStatusRunning; });
    }
}

void ps3dream_quit(void) {
    if (g_status.load() != Ps3DreamStatusStopped && g_status.load() != Ps3DreamStatusUnknown) {
        std::unique_lock lock(g_emu_mutex);
        g_status.store(Ps3DreamStatusRequestStop);
        g_emu_cond.wait(lock, []{
            auto s = g_status.load();
            return s == Ps3DreamStatusStopped || s == Ps3DreamStatusUnknown;
        });
    }
}

bool ps3dream_is_running(void) {
    return g_status.load() == Ps3DreamStatusRunning;
}

bool ps3dream_is_paused(void) {
    return g_status.load() == Ps3DreamStatusPaused;
}

int ps3dream_get_status(void) {
    return g_status.load();
}

void ps3dream_key_event(int key_code, bool pressed, int value) {
    auto* pad_thr = g_fxo->try_get<named_thread<pad_thread>>();
    if (pad_thr) {
        auto handler = pad_thr->get_handlers().at(pad_handler::keyboard);
        auto ios_pad = std::dynamic_pointer_cast<ios_virtual_pad_handler>(handler);
        if (ios_pad) {
            ios_pad->Key(static_cast<u32>(key_code), pressed, static_cast<u16>(value));
        }
    }
}

void ps3dream_set_surface(void* metal_layer, int width, int height) {
    CAMetalLayer* layer = (__bridge CAMetalLayer*)metal_layer;
    ios_window_set_layer(layer);
    ios_window_resize(width, height);
}

void ps3dream_resize(int width, int height) {
    ios_window_resize(width, height);
}

bool ps3dream_install_firmware(const char* pup_path) {
    fs::file pup_f(pup_path);
    if (!pup_f) return false;

    pup_object pup(std::move(pup_f));
    if (pup.operator pup_error() != pup_error::ok) return false;

    fs::file update_files_f = pup.get_file(0x300);
    if (!update_files_f) return false;

    tar_object update_files(update_files_f);
    auto filenames = update_files.get_filenames();

    filenames.erase(std::remove_if(filenames.begin(), filenames.end(),
        [](const std::string& s) { return s.find("dev_flash_") == umax; }),
        filenames.end());

    g_fxo->reset();
    vfs::mount("/dev_flash", g_cfg_vfs.get_dev_flash());

    for (const auto& fn : filenames) {
        auto stream = update_files.get_file(fn);
        if (stream->m_file_handler) {
            stream->m_file_handler->handle_file_op(*stream, 0, stream->get_size(umax), nullptr);
        }
        fs::file update_file = fs::make_stream(std::move(stream->data));
        SCEDecrypter dec(update_file);
        dec.LoadHeaders();
        dec.LoadMetadata(SCEPKG_ERK, SCEPKG_RIV);
        dec.DecryptData();
        auto dev_flash_tar_f = dec.MakeFile();
        if (dev_flash_tar_f.size() < 3) return false;
        tar_object dev_flash_tar(dev_flash_tar_f[2]);
        if (!dev_flash_tar.extract()) return false;
    }
    return true;
}

bool ps3dream_install_pkg(const char* pkg_path) {
    std::deque<package_reader> readers;
    readers.emplace_back(std::string(pkg_path));
    std::deque<std::string> bootable_paths;
    auto result = package_reader::extract_data(readers, bootable_paths);
    return result.error == package_install_result::error_type::no_error;
}

const char* ps3dream_get_gpu_info(void) {
    static std::string info;
    info = "MoltenVK (Vulkan -> Metal)";
    return info.c_str();
}

const char* ps3dream_get_cpu_info(void) {
    static std::string info;
    info = "Apple Silicon (ARM64)";
    return info.c_str();
}

const char* ps3dream_get_firmware_version(void) {
    static std::string ver;
    ver = utils::get_firmware_version();
    return ver.c_str();
}

const char* ps3dream_get_version(void) {
    return "Ps3Dream v1.0 (RPCS3 based)";
}

void ps3dream_set_log_callback(Ps3DreamLogCallback callback) { g_log_callback = callback; }
void ps3dream_set_status_callback(Ps3DreamStatusCallback callback) { g_status_callback = callback; }
void ps3dream_set_frame_callback(Ps3DreamFrameCallback callback) { g_frame_callback = callback; }
