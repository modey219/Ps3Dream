// ios_link_stub.cpp
// Link-time stubs for symbols that librpcs3_emu.a references but whose source
// TUs are not compiled on iOS (NP/upnp stack, PS Move tracker, USB emulated
// devices, AArch64 CPU backend, etc.). All bodies are no-ops so the app still
// links; the corresponding subsystems simply stay inert on iOS.

#include <array>
#include <chrono>
#include <cstring>
#include <functional>
#include <memory>
#include <optional>
#include <set>
#include <string>
#include <string_view>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>
#include <sys/socket.h>
#include <netinet/in.h>

using namespace std::chrono;
using namespace std::literals;

#include "util/types.hpp"
#include "Utilities/StrFmt.h"

// Minimal forward declarations for types we need
using socket_type = int;
enum class IPV6_SUPPORT : int { DISABLED = 0, ENABLED = 1 };
enum class thread_state : int {};
struct ucontext_t;
struct ppu_static_module;
struct ppu_module_manager { static ppu_static_module cellDmuxPamf; };

// SceNpError / SceNpTrophyError enums (from sceNp.h)
#include "Emu/Cell/Modules/sceNp.h"
#include "Emu/Cell/Modules/sceNpTrophy.h"

// ---------------------------------------------------------------------------
// PPU static module registrations (empty stubs).
// ---------------------------------------------------------------------------
const ppu_static_module ppu_module_manager::cellDmuxPamf("cellDmuxPamf", [](){});
const ppu_static_module ppu_module_manager::cellSysutilNpEula("cellSysutilNpEula", [](){});
const ppu_static_module ppu_module_manager::sceNp("sceNp", [](){});
const ppu_static_module ppu_module_manager::sceNp2("sceNp2", [](){});
const ppu_static_module ppu_module_manager::sceNpBasicLimited("sceNpBasicLimited", [](){});
const ppu_static_module ppu_module_manager::sceNpClans("sceNpClans", [](){});
const ppu_static_module ppu_module_manager::sceNpCommerce2("sceNpCommerce2", [](){});
const ppu_static_module ppu_module_manager::sceNpMatchingInt("sceNpMatchingInt", [](){});
const ppu_static_module ppu_module_manager::sceNpPlus("sceNpPlus", [](){});
const ppu_static_module ppu_module_manager::sceNpSns("sceNpSns", [](){});
const ppu_static_module ppu_module_manager::sceNpTrophy("sceNpTrophy", [](){});
const ppu_static_module ppu_module_manager::sceNpTus("sceNpTus", [](){});
const ppu_static_module ppu_module_manager::sceNpUtil("sceNpUtil", [](){});

// ---------------------------------------------------------------------------
// Enum -> string formatters referenced by lv2.cpp.
// ---------------------------------------------------------------------------
template <>
void fmt_class_string<SceNpError>::format(std::string& out, u64 arg)
{
	format_enum(out, arg, [](SceNpError value) -> const char*
	{
		switch (value)
		{
		case SCE_NP_ERROR_NOT_INITIALIZED: return "SCE_NP_ERROR_NOT_INITIALIZED";
		case SCE_NP_ERROR_ALREADY_INITIALIZED: return "SCE_NP_ERROR_ALREADY_INITIALIZED";
		case SCE_NP_ERROR_INVALID_ARGUMENT: return "SCE_NP_ERROR_INVALID_ARGUMENT";
		case SCE_NP_ERROR_OUT_OF_MEMORY: return "SCE_NP_ERROR_OUT_OF_MEMORY";
		case SCE_NP_ERROR_ID_NO_SPACE: return "SCE_NP_ERROR_ID_NO_SPACE";
		case SCE_NP_ERROR_ID_NOT_FOUND: return "SCE_NP_ERROR_ID_NOT_FOUND";
		case SCE_NP_ERROR_SESSION_RUNNING: return "SCE_NP_ERROR_SESSION_RUNNING";
		case SCE_NP_ERROR_LOGINID_ALREADY_EXISTS: return "SCE_NP_ERROR_LOGINID_ALREADY_EXISTS";
		case SCE_NP_ERROR_INVALID_TICKET_SIZE: return "SCE_NP_ERROR_INVALID_TICKET_SIZE";
		case SCE_NP_ERROR_INVALID_STATE: return "SCE_NP_ERROR_INVALID_STATE";
		case SCE_NP_ERROR_ABORTED: return "SCE_NP_ERROR_ABORTED";
		case SCE_NP_ERROR_OFFLINE: return "SCE_NP_ERROR_OFFLINE";
		case SCE_NP_ERROR_VARIANT_ACCOUNT_ID: return "SCE_NP_ERROR_VARIANT_ACCOUNT_ID";
		case SCE_NP_ERROR_GET_CLOCK: return "SCE_NP_ERROR_GET_CLOCK";
		case SCE_NP_ERROR_INSUFFICIENT_BUFFER: return "SCE_NP_ERROR_INSUFFICIENT_BUFFER";
		case SCE_NP_ERROR_EXPIRED_TICKET: return "SCE_NP_ERROR_EXPIRED_TICKET";
		case SCE_NP_ERROR_TICKET_PARAM_NOT_FOUND: return "SCE_NP_ERROR_TICKET_PARAM_NOT_FOUND";
		case SCE_NP_ERROR_UNSUPPORTED_TICKET_VERSION: return "SCE_NP_ERROR_UNSUPPORTED_TICKET_VERSION";
		case SCE_NP_ERROR_TICKET_STATUS_CODE_INVALID: return "SCE_NP_ERROR_TICKET_STATUS_CODE_INVALID";
		case SCE_NP_ERROR_INVALID_TICKET_VERSION: return "SCE_NP_ERROR_INVALID_TICKET_VERSION";
		case SCE_NP_ERROR_ALREADY_USED: return "SCE_NP_ERROR_ALREADY_USED";
		case SCE_NP_ERROR_DIFFERENT_USER: return "SCE_NP_ERROR_DIFFERENT_USER";
		case SCE_NP_ERROR_ALREADY_DONE: return "SCE_NP_ERROR_ALREADY_DONE";
		default: break;
		}

		return unknown;
	});
}

template <>
void fmt_class_string<SceNpTrophyError>::format(std::string& out, u64 arg)
{
	format_enum(out, arg, [](SceNpTrophyError value) -> const char*
	{
		switch (value)
		{
		case SCE_NP_TROPHY_ERROR_ALREADY_INITIALIZED: return "SCE_NP_TROPHY_ERROR_ALREADY_INITIALIZED";
		case SCE_NP_TROPHY_ERROR_NOT_INITIALIZED: return "SCE_NP_TROPHY_ERROR_NOT_INITIALIZED";
		case SCE_NP_TROPHY_ERROR_NOT_SUPPORTED: return "SCE_NP_TROPHY_ERROR_NOT_SUPPORTED";
		case SCE_NP_TROPHY_ERROR_CONTEXT_NOT_REGISTERED: return "SCE_NP_TROPHY_ERROR_CONTEXT_NOT_REGISTERED";
		case SCE_NP_TROPHY_ERROR_OUT_OF_MEMORY: return "SCE_NP_TROPHY_ERROR_OUT_OF_MEMORY";
		case SCE_NP_TROPHY_ERROR_INVALID_ARGUMENT: return "SCE_NP_TROPHY_ERROR_INVALID_ARGUMENT";
		case SCE_NP_TROPHY_ERROR_EXCEEDS_MAX: return "SCE_NP_TROPHY_ERROR_EXCEEDS_MAX";
		case SCE_NP_TROPHY_ERROR_INSUFFICIENT: return "SCE_NP_TROPHY_ERROR_INSUFFICIENT";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_CONTEXT: return "SCE_NP_TROPHY_ERROR_UNKNOWN_CONTEXT";
		case SCE_NP_TROPHY_ERROR_INVALID_FORMAT: return "SCE_NP_TROPHY_ERROR_INVALID_FORMAT";
		case SCE_NP_TROPHY_ERROR_BAD_RESPONSE: return "SCE_NP_TROPHY_ERROR_BAD_RESPONSE";
		case SCE_NP_TROPHY_ERROR_INVALID_GRADE: return "SCE_NP_TROPHY_ERROR_INVALID_GRADE";
		case SCE_NP_TROPHY_ERROR_INVALID_CONTEXT: return "SCE_NP_TROPHY_ERROR_INVALID_CONTEXT";
		case SCE_NP_TROPHY_ERROR_PROCESSING_ABORTED: return "SCE_NP_TROPHY_ERROR_PROCESSING_ABORTED";
		case SCE_NP_TROPHY_ERROR_ABORT: return "SCE_NP_TROPHY_ERROR_ABORT";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_HANDLE: return "SCE_NP_TROPHY_ERROR_UNKNOWN_HANDLE";
		case SCE_NP_TROPHY_ERROR_LOCKED: return "SCE_NP_TROPHY_ERROR_LOCKED";
		case SCE_NP_TROPHY_ERROR_HIDDEN: return "SCE_NP_TROPHY_ERROR_HIDDEN";
		case SCE_NP_TROPHY_ERROR_CANNOT_UNLOCK_PLATINUM: return "SCE_NP_TROPHY_ERROR_CANNOT_UNLOCK_PLATINUM";
		case SCE_NP_TROPHY_ERROR_ALREADY_UNLOCKED: return "SCE_NP_TROPHY_ERROR_ALREADY_UNLOCKED";
		case SCE_NP_TROPHY_ERROR_INVALID_TYPE: return "SCE_NP_TROPHY_ERROR_INVALID_TYPE";
		case SCE_NP_TROPHY_ERROR_INVALID_HANDLE: return "SCE_NP_TROPHY_ERROR_INVALID_HANDLE";
		case SCE_NP_TROPHY_ERROR_INVALID_NP_COMM_ID: return "SCE_NP_TROPHY_ERROR_INVALID_NP_COMM_ID";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_NP_COMM_ID: return "SCE_NP_TROPHY_ERROR_UNKNOWN_NP_COMM_ID";
		case SCE_NP_TROPHY_ERROR_DISC_IO: return "SCE_NP_TROPHY_ERROR_DISC_IO";
		case SCE_NP_TROPHY_ERROR_CONF_DOES_NOT_EXIST: return "SCE_NP_TROPHY_ERROR_CONF_DOES_NOT_EXIST";
		case SCE_NP_TROPHY_ERROR_UNSUPPORTED_FORMAT: return "SCE_NP_TROPHY_ERROR_UNSUPPORTED_FORMAT";
		case SCE_NP_TROPHY_ERROR_ALREADY_INSTALLED: return "SCE_NP_TROPHY_ERROR_ALREADY_INSTALLED";
		case SCE_NP_TROPHY_ERROR_BROKEN_DATA: return "SCE_NP_TROPHY_ERROR_BROKEN_DATA";
		case SCE_NP_TROPHY_ERROR_VERIFICATION_FAILURE: return "SCE_NP_TROPHY_ERROR_VERIFICATION_FAILURE";
		case SCE_NP_TROPHY_ERROR_INVALID_TROPHY_ID: return "SCE_NP_TROPHY_ERROR_INVALID_TROPHY_ID";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_TROPHY_ID: return "SCE_NP_TROPHY_ERROR_UNKNOWN_TROPHY_ID";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_TITLE: return "SCE_NP_TROPHY_ERROR_UNKNOWN_TITLE";
		case SCE_NP_TROPHY_ERROR_UNKNOWN_FILE: return "SCE_NP_TROPHY_ERROR_UNKNOWN_FILE";
		case SCE_NP_TROPHY_ERROR_DISC_NOT_MOUNTED: return "SCE_NP_TROPHY_ERROR_DISC_NOT_MOUNTED";
		case SCE_NP_TROPHY_ERROR_SHUTDOWN: return "SCE_NP_TROPHY_ERROR_SHUTDOWN";
		case SCE_NP_TROPHY_ERROR_TITLE_ICON_NOT_FOUND: return "SCE_NP_TROPHY_ERROR_TITLE_ICON_NOT_FOUND";
		case SCE_NP_TROPHY_ERROR_TROPHY_ICON_NOT_FOUND: return "SCE_NP_TROPHY_ERROR_TROPHY_ICON_NOT_FOUND";
		case SCE_NP_TROPHY_ERROR_INSUFFICIENT_DISK_SPACE: return "SCE_NP_TROPHY_ERROR_INSUFFICIENT_DISK_SPACE";
		case SCE_NP_TROPHY_ERROR_ILLEGAL_UPDATE: return "SCE_NP_TROPHY_ERROR_ILLEGAL_UPDATE";
		case SCE_NP_TROPHY_ERROR_SAVEDATA_USER_DOES_NOT_MATCH: return "SCE_NP_TROPHY_ERROR_SAVEDATA_USER_DOES_NOT_MATCH";
		case SCE_NP_TROPHY_ERROR_TROPHY_ID_DOES_NOT_EXIST: return "SCE_NP_TROPHY_ERROR_TROPHY_ID_DOES_NOT_EXIST";
		case SCE_NP_TROPHY_ERROR_SERVICE_UNAVAILABLE: return "SCE_NP_TROPHY_ERROR_SERVICE_UNAVAILABLE";
		case SCE_NP_TROPHY_ERROR_UNKNOWN: return "SCE_NP_TROPHY_ERROR_UNKNOWN";
		default: break;
		}

		return unknown;
	});
}

// ---------------------------------------------------------------------------
// Trophy notification base
// ---------------------------------------------------------------------------
TrophyNotificationBase::~TrophyNotificationBase() {}

// ---------------------------------------------------------------------------
// NP networking helpers (np_handler, dnshook, signaling_handler)
// ---------------------------------------------------------------------------
namespace np
{
	class np_handler
	{
	public:
		np_handler();
		np_handler(utils::serial& ar);
		~np_handler();
		void save(utils::serial& ar);
		const std::array<u8, 6>& get_ether_addr() const;
		const std::string& get_hostname() const;
		u32 get_local_ip_addr() const;
		u32 get_public_ip_addr() const;
		u32 get_dns_ip() const;
		u32 get_bind_ip() const;
		s32 get_net_status() const;
		s32 get_upnp_status() const;
		void operator()();
		void upnp_add_port_mapping(u16 internal_port, std::string_view protocol);
		void upnp_remove_port_mapping(u16 internal_port, std::string_view protocol);
	};

	std::string ip_to_string(u32 addr);
	void init_np_handler_dependencies();
	void close_socket(socket_type socket);
	void set_socket_non_blocking(socket_type socket);
	bool is_ipv6_supported(std::optional<IPV6_SUPPORT> force_state);
	s32 sendto_possibly_ipv6(socket_type native_socket, const char* data, u32 size, const sockaddr_in* addr, int native_flags);
	sockaddr_in6 sockaddr_to_sockaddr6(const sockaddr_in& addr);
	sockaddr_in sockaddr6_to_sockaddr(const sockaddr_in6& addr);

	class dnshook
	{
	public:
		dnshook();
		void add_dns_spy(u32 sock);
		void remove_dns_spy(u32 sock);
		bool is_dns(u32 sock);
		bool is_dns_queue(u32 sock);
		std::vector<u8> get_dns_packet(u32 sock);
		s32 analyze_dns_packet(s32 s, const u8* buf, u32 len);
	};
}

class signaling_handler
{
public:
	signaling_handler();
	void operator()();
	void wake_up();
	signaling_handler& operator=(thread_state);
};

np::np_handler::np_handler() {}
np::np_handler::np_handler(utils::serial& ar) {}
np::np_handler::~np_handler() {}
void np::np_handler::save(utils::serial& ar) {}
const std::array<u8, 6>& np::np_handler::get_ether_addr() const { static const std::array<u8, 6> empty{}; return empty; }
const std::string& np::np_handler::get_hostname() const { static const std::string empty; return empty; }
u32 np::np_handler::get_local_ip_addr() const { return 0; }
u32 np::np_handler::get_public_ip_addr() const { return 0; }
u32 np::np_handler::get_dns_ip() const { return 0; }
u32 np::np_handler::get_bind_ip() const { return 0; }
s32 np::np_handler::get_net_status() const { return 0; }
s32 np::np_handler::get_upnp_status() const { return 0; }
void np::np_handler::operator()() {}
void np::np_handler::upnp_add_port_mapping(u16, std::string_view) {}
void np::np_handler::upnp_remove_port_mapping(u16, std::string_view) {}
std::string np::ip_to_string(u32) { return "0.0.0.0"; }
void np::init_np_handler_dependencies() {}
void np::close_socket(socket_type) {}
void np::set_socket_non_blocking(socket_type) {}
bool np::is_ipv6_supported(std::optional<IPV6_SUPPORT>) { return false; }
s32 np::sendto_possibly_ipv6(socket_type, const char*, u32, const sockaddr_in*, int) { return 0; }
sockaddr_in6 np::sockaddr_to_sockaddr6(const sockaddr_in&) { return {}; }
sockaddr_in np::sockaddr6_to_sockaddr(const sockaddr_in6&) { return {}; }
np::dnshook::dnshook() {}
void np::dnshook::add_dns_spy(u32) {}
void np::dnshook::remove_dns_spy(u32) {}
bool np::dnshook::is_dns(u32) { return false; }
bool np::dnshook::is_dns_queue(u32) { return false; }
std::vector<u8> np::dnshook::get_dns_packet(u32) { return {}; }
s32 np::dnshook::analyze_dns_packet(s32, const u8*, u32) { return 0; }
signaling_handler::signaling_handler() {}
void signaling_handler::operator()() {}
void signaling_handler::wake_up() {}
signaling_handler& signaling_handler::operator=(thread_state) { return *this; }

// ---------------------------------------------------------------------------
// AArch64 CPU backend
// ---------------------------------------------------------------------------
namespace aarch64
{
	std::string get_cpu_brand();
	enum class fault_reason : int { undefined = 0 };
	fault_reason decode_fault_reason(const ucontext_t* uctx);
}
std::string aarch64::get_cpu_brand() { return "Apple AArch64"; }
aarch64::fault_reason aarch64::decode_fault_reason(const ucontext_t*) { return fault_reason::undefined; }

// SPU LLVM recompiler glue
struct spu_llvm_compile_context;
void spu_llvm_set_compile_context(spu_llvm_compile_context*) noexcept {}

// Pad thread global
namespace pad { class pad_thread; pad_thread* g_pad_thread = nullptr; }

// ---------------------------------------------------------------------------
// PS Move tracking (ps_move_tracker template stubs)
// ---------------------------------------------------------------------------
struct ps_move_tracker_tag {};
template <bool> struct ps_move_tracker
{
	ps_move_tracker();
	~ps_move_tracker();
	void set_image_data(const void* buf, u64 size, u32 width, u32 height, s32 format);
	void process_image();
	void set_active(u32 index, bool active);
	void set_hue(u32 index, u16 hue);
	void set_hue_threshold(u32 index, u16 threshold);
	void set_saturation_threshold(u32 index, u16 threshold);
	std::tuple<u8, u8, u8> hsv_to_rgb(u16 hue, f32 saturation, f32 value);
	std::tuple<s16, f32, f32> rgb_to_hsv(f32 r, f32 g, f32 b);
};
template <> ps_move_tracker<false>::ps_move_tracker() {}
template <> ps_move_tracker<false>::~ps_move_tracker() {}
template <> void ps_move_tracker<false>::set_image_data(const void*, u64, u32, u32, s32) {}
template <> void ps_move_tracker<false>::process_image() {}
template <> void ps_move_tracker<false>::set_active(u32, bool) {}
template <> void ps_move_tracker<false>::set_hue(u32, u16) {}
template <> void ps_move_tracker<false>::set_hue_threshold(u32, u16) {}
template <> void ps_move_tracker<false>::set_saturation_threshold(u32, u16) {}
template <> std::tuple<u8, u8, u8> ps_move_tracker<false>::hsv_to_rgb(u16, f32, f32) { return {0, 0, 0}; }
template <> std::tuple<s16, f32, f32> ps_move_tracker<false>::rgb_to_hsv(f32, f32, f32) { return {0, 0.0f, 0.0f}; }

// ---------------------------------------------------------------------------
// USB devices (minimal forward-declared stubs)
// ---------------------------------------------------------------------------
struct UsbDeviceDescriptor
{
	le_t<u16, 1> bcdUSB; u8 bDeviceClass; u8 bDeviceSubClass; u8 bDeviceProtocol;
	u8 bMaxPacketSize0; le_t<u16, 1> idVendor; le_t<u16, 1> idProduct;
	le_t<u16, 1> bcdDevice; u8 iManufacturer; u8 iProduct; u8 iSerialNumber;
	u8 bNumConfigurations;
};

struct UsbTransfer
{
	s32 result = 0; u32 count = 0; bool busy = false;
};

struct usb_device
{
	usb_device(const std::array<u8, 7>& location) : location(location) {}
	virtual ~usb_device() = default;
	u64 get_timestamp() { return 0; }
	void get_location(u8* loc) const { std::memcpy(loc, this->location.data(), 7); }
	virtual void read_descriptors() {}
	virtual u32 get_configuration(u8* buf) { return current_config; }
	virtual bool set_configuration(u8 cfg) { current_config = cfg; return true; }
	virtual bool set_interface(u8 int_num, u8 alt) { current_interface = int_num; current_altsetting = alt; return true; }
	virtual void control_transfer(u8, u8, u16, u16, u16, u32, u8*, UsbTransfer*) {}
	virtual void interrupt_transfer(u32, u8*, u32, UsbTransfer*) {}
	virtual void isochronous_transfer(UsbTransfer*) {}
protected:
	u8 current_config = 1;
	u8 current_interface = 0;
	u8 current_altsetting = 0;
	std::array<u8, 7> location{};
};

struct usb_device_emulated : usb_device
{
	usb_device_emulated(const std::array<u8, 7>& loc) : usb_device(loc) {}
	usb_device_emulated(const UsbDeviceDescriptor&, const std::array<u8, 7>& loc) : usb_device(loc) {}
	bool open_device() { return true; }
	void add_string(std::string str) { strings.emplace_back(std::move(str)); }
protected:
	std::vector<std::string> strings;
};

enum class MicType { SingStar, Logitech, Rocksmith };

struct usb_device_mic : usb_device_emulated
{
	usb_device_mic(u32 ci, const std::array<u8, 7>& loc, MicType mt)
		: usb_device_emulated(loc), m_controller_index(ci), m_mic_type(mt) {}
	u32 m_controller_index;
	MicType m_mic_type;
};

class usb_device_vfs : public usb_device_emulated
{
public:
	usb_device_vfs(const std::array<u8, 7>& loc) : usb_device_emulated(loc) {}
	~usb_device_vfs() {}
};
