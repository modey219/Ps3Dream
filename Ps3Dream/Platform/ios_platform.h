// Ps3Dream iOS Platform Layer
// Replaces Android-specific headers and provides iOS equivalents

#pragma once

#ifdef __APPLE__
#include <TargetConditionals.h>
#endif

// Replaces Android NDK headers
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>
#include <sys/resource.h>
#include <sys/mman.h>
#include <dlfcn.h>

// ANativeWindow -> CAMetalLayer bridge (defined in ios_window.h)
#include "ios_window.h"

// Logging (replaces __android_log)
#include "ios_log.h"

// Memory mapping (replaces Android mmap)
#include "ios_mmap.h"
