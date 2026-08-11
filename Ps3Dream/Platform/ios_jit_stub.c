// Ps3Dream iOS - No-op stub for macOS-only pthread_jit_write_protect_np
//
// rpcs3 wraps JIT code writes with pthread_jit_write_protect_np(), which is
// exported by macOS libSystem (macOS 11+) but NOT by the iOS SDK's libSystem,
// so the iOS linker reports it as an undefined symbol.
//
// On iOS, JIT pages are created with MAP_JIT / RWX mmap (see ios_jit.cpp) and
// the write-protect toggle is not needed, so a no-op is the correct behaviour
// here rather than a compatibility hack.

void pthread_jit_write_protect_np(int enabled)
{
	(void)enabled;
}
