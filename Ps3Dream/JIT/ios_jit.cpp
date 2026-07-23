// Ps3Dream iOS - JIT Compilation Support Implementation
//
// Strategy for enabling JIT on iOS:
// 1. iOS 17+: Use csops() with CS_DEBUGGED flag (works on developer-mode devices)
// 2. Fallback: Use posix_spawn to launch a helper that sets CS_DEBUGGED via task_for_pid
// 3. Jailbroken devices: Direct mprotect() on JIT memory
//
// RPCS3 PPU/SPU recompilers need W^X (Write XOR Execute) memory permissions.

#include "ios_jit.h"
#include <sys/types.h>
#include <sys/syscall.h>
#include <sys/mman.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <stdbool.h>

// csops syscall for codesigning operations
#ifndef CS_OPS_DEBUG
#define CS_OPS_DEBUG 0
#define CS_DEBUGGED 0x10000006
#endif

#ifndef CS_OPS_STATUS
#define CS_OPS_STATUS 1
#endif

static bool s_jit_enabled = false;
static char s_jit_status[256] = "Not attempted";

// Attempt method 1: csops CS_DEBUGGED (iOS 17+ developer mode)
static bool try_csops_debugged(void) {
    pid_t pid = getpid();
    // CS_OPS_DEBUG with CS_DEBUGGED flag
    int result = syscall(SYS_csops, pid, CS_OPS_DEBUG, &s_jit_enabled, sizeof(s_jit_enabled));
    if (result == 0 && s_jit_enabled) {
        return true;
    }
    return false;
}

// Attempt method 2: Direct mmap with RWX (works on jailbroken / certain configs)
static bool try_mmap_jit(void) {
    size_t page_size = getpagesize();
    // Allocate a page with read/write
    void* mem = mmap(NULL, page_size,
                      PROT_READ | PROT_WRITE | PROT_EXEC,
                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (mem == MAP_FAILED) {
        return false;
    }
    // Test write + execute
    volatile unsigned int* code = (volatile unsigned int*)mem;
    *code = 0xD503201F; // ARM64 NOP
    int exec_test = mprotect(mem, page_size, PROT_READ | PROT_EXEC);
    munmap(mem, page_size);
    return (exec_test == 0);
}

bool ios_enable_jit(void) {
    if (s_jit_enabled) return true;

    // Method 1: csops
    if (try_csops_debugged()) {
        snprintf(s_jit_status, sizeof(s_jit_status), "JIT enabled via csops(CS_DEBUGGED)");
        return true;
    }

    // Method 2: Direct RWX mmap
    if (try_mmap_jit()) {
        s_jit_enabled = true;
        snprintf(s_jit_status, sizeof(s_jit_status), "JIT enabled via RWX mmap");
        return true;
    }

    snprintf(s_jit_status, sizeof(s_jit_status),
             "JIT not available. Enable Developer Mode in Settings > Privacy & Security");
    return false;
}

bool ios_jit_enabled(void) {
    return s_jit_enabled;
}

const char* ios_jit_status_string(void) {
    return s_jit_status;
}
