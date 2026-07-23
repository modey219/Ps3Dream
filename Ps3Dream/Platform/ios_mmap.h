// Ps3Dream iOS - Memory mapping abstraction

#pragma once

#include <sys/mman.h>
#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif

// iOS equivalent of Android's mmap/mprotect
// RPCS3 uses mmap for virtual memory management

static inline void* ios_mmap_anonymous(size_t length, int prot, int flags) {
    return mmap(NULL, length, prot, flags | MAP_ANONYMOUS, -1, 0);
}

static inline int ios_munmap(void* addr, size_t length) {
    return munmap(addr, length);
}

#ifdef __cplusplus
}
#endif
