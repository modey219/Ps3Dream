// ios_link_stub.cpp
// Link-time stubs for symbols that librpcs3_emu.a references but whose source
// TUs are not compiled on iOS (NP/upnp stack, PS Move tracker, USB emulated
// devices, AArch64 CPU backend, etc.). All bodies are no-ops so the app still
// links; the corresponding subsystems simply stay inert on iOS.
//
// The rpcs3 source root and Utilities/3rdparty
// include paths must be on the clang++ include path (see build.yml).

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

using namespace std::chrono;
using namespace std::literals;

#include "util/types.hpp"

#include "Utilities/Thread.h"

#include "Emu/Cell/PPUModule.h"
#include "Emu/Cell/Modules/sceNp.h"
#include "Emu/Cell/Modules/sceNpTrophy.h"

#include "Emu/Io/ps_move_tracker.h"
#include "Emu/Io/usb_device.h"
#include "Emu/Io/usb_microphone.h"

#include "Emu/CPU/AArch64/AArch64Signal.h"

#include "Utilities/StrFmt.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <optional>

// Forward declarations for types from non-compiled networking TUs
enum class socket_type : int {};
enum class IPV6_SUPPORT : int { DISABLED = 0, ENABLED = 1 };
enum class thread_state : int {};
struct ucontext_t;

namespace np
{
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

// ---------------------------------------------------------------------------
// Removed HLE module registrations (empty module bodies).
// The TUs that normally define these (sceNp.cpp, sceNpTrophy.cpp, ...) are
// stripped from Emu/CMakeLists.txt because they pull in wolfssl/protobuf.
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
// Trophy notification base (its .cpp TU is not compiled on iOS).
// ---------------------------------------------------------------------------
TrophyNotificationBase::~TrophyNotificationBase()
{
}

// ---------------------------------------------------------------------------
// NP networking helpers (np_handler.cpp / np_helpers.cpp / np_dnshook.cpp
// are not compiled; np_handler.h pulls in wolfssl via rpcn_client.h so only a
// minimal local class shape is used here).
// ---------------------------------------------------------------------------
namespace utils
{
	class serial;
}

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
}

np::np_handler::np_handler()
{
}

np::np_handler::np_handler(utils::serial& ar)
{
}

np::np_handler::~np_handler()
{
}

void np::np_handler::save(utils::serial& ar)
{
}

const std::array<u8, 6>& np::np_handler::get_ether_addr() const
{
	static const std::array<u8, 6> empty{};
	return empty;
}

const std::string& np::np_handler::get_hostname() const
{
	static const std::string empty;
	return empty;
}

u32 np::np_handler::get_local_ip_addr() const { return 0; }
u32 np::np_handler::get_public_ip_addr() const { return 0; }
u32 np::np_handler::get_dns_ip() const { return 0; }
u32 np::np_handler::get_bind_ip() const { return 0; }
s32 np::np_handler::get_net_status() const { return 0; }
s32 np::np_handler::get_upnp_status() const { return 0; }

void np::np_handler::operator()()
{
}

void np::np_handler::upnp_add_port_mapping(u16 internal_port, std::string_view protocol)
{
}

void np::np_handler::upnp_remove_port_mapping(u16 internal_port, std::string_view protocol)
{
}

std::string np::ip_to_string(u32 addr)
{
	return "0.0.0.0";
}

void np::init_np_handler_dependencies()
{
}

void np::close_socket(socket_type socket)
{
}

void np::set_socket_non_blocking(socket_type socket)
{
}

bool np::is_ipv6_supported(std::optional<IPV6_SUPPORT> force_state)
{
	return false;
}

s32 np::sendto_possibly_ipv6(socket_type native_socket, const char* data, u32 size, const sockaddr_in* addr, int native_flags)
{
	return static_cast<s32>(size);
}

sockaddr_in6 np::sockaddr_to_sockaddr6(const sockaddr_in& addr)
{
	sockaddr_in6 result{};
	return result;
}

sockaddr_in np::sockaddr6_to_sockaddr(const sockaddr_in6& addr)
{
	sockaddr_in result{};
	return result;
}

// DNS hook (np_dnshook.cpp).
np::dnshook::dnshook()
{
}

void np::dnshook::add_dns_spy(u32 sock)
{
}

void np::dnshook::remove_dns_spy(u32 sock)
{
}

bool np::dnshook::is_dns(u32 sock)
{
	return false;
}

bool np::dnshook::is_dns_queue(u32 sock)
{
	return false;
}

std::vector<u8> np::dnshook::get_dns_packet(u32 sock)
{
	return {};
}

s32 np::dnshook::analyze_dns_packet(s32 s, const u8* buf, u32 len)
{
	return 0;
}

// Signaling manager (signaling_handler.cpp).
signaling_handler::signaling_handler()
{
}

void signaling_handler::operator()()
{
}

void signaling_handler::wake_up()
{
}

signaling_handler& signaling_handler::operator=(thread_state)
{
	return *this;
}

// ---------------------------------------------------------------------------
// AArch64 CPU backend (not compiled on iOS).
// ---------------------------------------------------------------------------
std::string aarch64::get_cpu_brand()
{
	return "Apple AArch64";
}

aarch64::fault_reason aarch64::decode_fault_reason(const ucontext_t* uctx)
{
	return aarch64::fault_reason::undefined;
}

// SPU LLVM recompiler glue (LLVM_AVAILABLE is not defined on iOS).
struct spu_llvm_compile_context;
void spu_llvm_set_compile_context(spu_llvm_compile_context* context) noexcept
{
}

// ---------------------------------------------------------------------------
// Pad thread global (pad_thread.cpp is not compiled on iOS).
// ---------------------------------------------------------------------------
namespace pad
{
	class pad_thread;
	pad_thread* g_pad_thread = nullptr;
}

// ---------------------------------------------------------------------------
// PS Move tracking (ps_move_tracker.cpp is not compiled on iOS).
// ---------------------------------------------------------------------------
template <>
ps_move_tracker<false>::ps_move_tracker()
{
}

template <>
ps_move_tracker<false>::~ps_move_tracker()
{
}

template <>
void ps_move_tracker<false>::set_image_data(const void* buf, u64 size, u32 width, u32 height, s32 format)
{
}

template <>
void ps_move_tracker<false>::process_image()
{
}

template <>
void ps_move_tracker<false>::set_active(u32 index, bool active)
{
}

template <>
void ps_move_tracker<false>::set_hue(u32 index, u16 hue)
{
}

template <>
void ps_move_tracker<false>::set_hue_threshold(u32 index, u16 threshold)
{
}

template <>
void ps_move_tracker<false>::set_saturation_threshold(u32 index, u16 threshold)
{
}

template <>
std::tuple<u8, u8, u8> ps_move_tracker<false>::hsv_to_rgb(u16 hue, f32 saturation, f32 value)
{
	return { 0, 0, 0 };
}

template <>
std::tuple<s16, f32, f32> ps_move_tracker<false>::rgb_to_hsv(f32 r, f32 g, f32 b)
{
	return { 0, 0.0f, 0.0f };
}

// ---------------------------------------------------------------------------
// USB devices (usb_device.cpp and the per-device TUs are not compiled on iOS).
// ---------------------------------------------------------------------------
usb_device::usb_device(const std::array<u8, 7>& location)
	: location(location)
{
}

u64 usb_device::get_timestamp()
{
	return 0;
}

void usb_device::get_location(u8* location) const
{
	std::memcpy(location, this->location.data(), 7);
}

void usb_device::read_descriptors()
{
}

u32 usb_device::get_configuration(u8* buf)
{
	return current_config;
}

bool usb_device::set_configuration(u8 cfg_num)
{
	current_config = cfg_num;
	return true;
}

bool usb_device::set_interface(u8 int_num, u8 alt_num)
{
	current_interface = int_num;
	current_altsetting = alt_num;
	return true;
}

usb_device_emulated::usb_device_emulated(const std::array<u8, 7>& location)
	: usb_device(location)
{
}

usb_device_emulated::usb_device_emulated(const UsbDeviceDescriptor& _device, const std::array<u8, 7>& location)
	: usb_device(location)
{
}

bool usb_device_emulated::open_device()
{
	return true;
}

void usb_device_emulated::control_transfer(u8 bmRequestType, u8 bRequest, u16 wValue, u16 wIndex, u16 wLength, u32 buf_size, u8* buf, UsbTransfer* transfer)
{
	if (transfer)
	{
		transfer->result = 0;
		transfer->count = 0;
		transfer->busy = false;
	}
}

void usb_device_emulated::interrupt_transfer(u32 buf_size, u8* buf, u32 endpoint, UsbTransfer* transfer)
{
	if (transfer)
	{
		transfer->result = 0;
		transfer->count = 0;
		transfer->busy = false;
	}
}

void usb_device_emulated::isochronous_transfer(UsbTransfer* transfer)
{
	if (transfer)
	{
		transfer->result = 0;
		transfer->count = 0;
		transfer->busy = false;
	}
}

void usb_device_emulated::add_string(std::string str)
{
	strings.emplace_back(std::move(str));
}

// USB microphone (usb_microphone.cpp).
usb_device_mic::usb_device_mic(u32 controller_index, const std::array<u8, 7>& location, MicType mic_type)
	: usb_device_emulated(location)
	, m_controller_index(controller_index)
	, m_mic_type(mic_type)
{
}

// USB VFS device (usb_vfs.cpp; avoids including Config.h).
namespace cfg
{
	struct device_info;
}

class usb_device_vfs : public usb_device_emulated
{
public:
	usb_device_vfs(const cfg::device_info& device_info, const std::array<u8, 7>& location);
	virtual ~usb_device_vfs();
};

usb_device_vfs::usb_device_vfs(const cfg::device_info& device_info, const std::array<u8, 7>& location)
	: usb_device_emulated(location)
{
}

usb_device_vfs::~usb_device_vfs()
{
}
