#pragma once
// Stub sys/prctl.h for iOS (Linux only)
static inline int prctl(int option, ...) { (void)option; return 0; }
