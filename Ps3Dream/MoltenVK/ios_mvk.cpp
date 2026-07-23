// Ps3Dream iOS - MoltenVK Integration Implementation
//
// MoltenVK is included as a static library (libMoltenVK.a) or framework.
// It provides a Vulkan 1.2 implementation on top of Apple's Metal API.
//
// This replaces Android's dynamic Vulkan loading (vkapi.cpp) with
// direct linking against MoltenVK's Vulkan implementation.

#include "ios_mvk.h"

#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

// MoltenVK provides standard Vulkan functions.
// When linked statically, they are available directly.
// We include the Vulkan headers without platform defines
// so MoltenVK's headers are used.

// MoltenVK function pointers (loaded from the MVK library)
static void* s_mvk_handle = NULL;
static bool s_mvk_initialized = false;

bool ios_mvk_initialize(void) {
    if (s_mvk_initialized) return true;

    // MoltenVK can be loaded from:
    // 1. Static linking (preferred for iOS)
    // 2. Dynamic framework (MoltenVK.framework)
    // 3. dylib (libMoltenVK.dylib)

    // Try framework first
    s_mvk_handle = dlopen("MoltenVK.framework/MoltenVK", RTLD_NOW);
    if (!s_mvk_handle) {
        // Try dylib
        s_mvk_handle = dlopen("libMoltenVK.dylib", RTLD_NOW);
    }

    if (!s_mvk_handle) {
        // Static linking: functions are available directly
        // This is the preferred path for iOS App Store apps
        s_mvk_initialized = true;
        return true;
    }

    s_mvk_initialized = true;
    return true;
}

void* ios_mvk_get_instance_proc_addr(const char* name) {
    if (s_mvk_handle) {
        return dlsym(s_mvk_handle, name);
    }
    // For static linking, Vulkan functions are in the binary
    return dlsym(RTLD_DEFAULT, name);
}

void* ios_mvk_get_device_proc_addr(const char* name) {
    return ios_mvk_get_instance_proc_addr(name);
}

void ios_mvk_shutdown(void) {
    if (s_mvk_handle) {
        dlclose(s_mvk_handle);
        s_mvk_handle = NULL;
    }
    s_mvk_initialized = false;
}
