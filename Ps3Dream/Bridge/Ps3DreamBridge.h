// Ps3Dream iOS - Core Emulator Bridge (Objective-C++)
//
// This file provides the C interface that Swift/Objective-C code can call,
// and bridges to the RPCS3 C++ emulator core.

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#import <UIKit/UIKit.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif

// C++ headers are only needed by the Objective-C++ implementation
// (Ps3DreamBridge.mm). They must NOT be visible to Swift's bridging
// header, which is compiled as C/Objective-C with no C++ standard
// library available.
#ifdef __cplusplus

#include <thread>
#include <string>
#include <atomic>
#include <functional>
#include <sstream>
#include <mutex>

// Forward declarations for RPCS3 types we need
#include "ps3dream_emulator.hpp"

#endif

#ifdef __cplusplus
extern "C" {
#endif

// ==================== Emulator State ====================

typedef NS_ENUM(NSInteger, Ps3DreamBootType) {
    Ps3DreamBootTypePath = 1,
    Ps3DreamBootTypeFD   = 2,
    Ps3DreamBootTypeURI  = 3,
};

typedef NS_ENUM(NSInteger, Ps3DreamStatus) {
    Ps3DreamStatusUnknown       = 0,
    Ps3DreamStatusRunning       = 1,
    Ps3DreamStatusStopped       = 2,
    Ps3DreamStatusPaused        = 3,
    Ps3DreamStatusRequestPause  = 4,
    Ps3DreamStatusRequestResume = 5,
    Ps3DreamStatusRequestStop   = 6,
};

// ==================== Core API ====================

// Initialize the emulator engine
void ps3dream_init(void);

// Boot a game from file path
bool ps3dream_boot_game(const char* game_path);

// Boot a game from ISO with file descriptor
bool ps3dream_boot_game_fd(int fd);

// Boot a game from URL
bool ps3dream_boot_game_uri(const char* uri);

// Start emulation (launches thread)
void ps3dream_boot(void);

// Pause emulation
void ps3dream_pause(void);

// Resume emulation
void ps3dream_resume(void);

// Stop emulation
void ps3dream_quit(void);

// Check if running
bool ps3dream_is_running(void);

// Check if paused
bool ps3dream_is_paused(void);

// Get current status
int ps3dream_get_status(void);

// Send key/button event
void ps3dream_key_event(int key_code, bool pressed, int value);

// Set the Metal surface for rendering
void ps3dream_set_surface(void* metal_layer, int width, int height);

// Window resize callback
void ps3dream_resize(int width, int height);

// ==================== Firmware/Package ====================

// Install PS3 firmware from PUP file
bool ps3dream_install_firmware(const char* pup_path);

// Install PKG file
bool ps3dream_install_pkg(const char* pkg_path);

// ==================== Info ====================

// Get GPU info string
const char* ps3dream_get_gpu_info(void);

// Get CPU info string
const char* ps3dream_get_cpu_info(void);

// Get firmware version
const char* ps3dream_get_firmware_version(void);

// Get RPCS3 version
const char* ps3dream_get_version(void);

// ==================== Config ====================

// Open YAML config from string, returns handle
long ps3dream_config_open(const char* config_str);

// Close config and return YAML string
const char* ps3dream_config_close(long handle);

// Load config entry by tag (format: "Section|key")
const char* ps3dream_config_load(long handle, const char* tag);

// Save config entry
void ps3dream_config_save(long handle, const char* tag, const char* value);

// ==================== PPU Cache ====================

// Pre-compile PPU cache for a game
bool ps3dream_precompile_ppu_cache(const char* path);

// ==================== Callbacks for Swift ====================

// Callback function types
typedef void (*Ps3DreamLogCallback)(const char* tag, const char* message, int level);
typedef void (*Ps3DreamStatusCallback)(int status);
typedef void (*Ps3DreamFrameCallback)(void* frame_data, int width, int height);

// Set callbacks
void ps3dream_set_log_callback(Ps3DreamLogCallback callback);
void ps3dream_set_status_callback(Ps3DreamStatusCallback callback);
void ps3dream_set_frame_callback(Ps3DreamFrameCallback callback);

#ifdef __cplusplus
}
#endif
