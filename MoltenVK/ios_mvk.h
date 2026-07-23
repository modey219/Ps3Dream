// Ps3Dream iOS - Vulkan Layer via MoltenVK
// Replaces Android's dlopen-based Vulkan loading with MoltenVK
//
// MoltenVK translates Vulkan API calls to Metal on Apple platforms.
// This replaces the Android vkapi.cpp which dynamically loads libvulkan.so.

#pragma once

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Initialize MoltenVK Vulkan layer
// Must be called before any Vulkan operations
bool ios_mvk_initialize(void);

// Get the VkInstanceProcAddr function from MoltenVK
void* ios_mvk_get_instance_proc_addr(const char* name);

// Get the VkDeviceProcAddr function from MoltenVK
void* ios_mvk_get_device_proc_addr(const char* name);

// Shutdown MoltenVK
void ios_mvk_shutdown(void);

#ifdef __cplusplus
}
#endif
