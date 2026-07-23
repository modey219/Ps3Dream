// Ps3Dream iOS - JIT Compilation Support
// Enables JIT on iOS 17+ using permissive entitlement or CS_DEBUGGED

#pragma once

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Attempt to enable JIT via multiple methods
// Returns true if JIT was successfully enabled
bool ios_enable_jit(void);

// Check if JIT is currently available
bool ios_jit_enabled(void);

// Get JIT status string for display
const char* ios_jit_status_string(void);

#ifdef __cplusplus
}
#endif
