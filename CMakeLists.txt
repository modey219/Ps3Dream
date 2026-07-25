# Ps3Dream iOS - Unified CMake Build System
# Builds the native emulator library from APS3E/RPCS3 sources
#
# Usage:
#   mkdir build-ios && cd build-ios
#   cmake .. -G Xcode -DCMAKE_SYSTEM_NAME=iOS \
#     -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
#     -DCMAKE_OSX_ARCHITECTURES=arm64
#   cmake --build . --config Release

cmake_minimum_required(VERSION 3.22)
project(Ps3Dream LANGUAGES C CXX OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ==================== iOS Configuration ====================
set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_OSX_DEPLOYMENT_TARGET 17.0 CACHE STRING "Minimum iOS version")
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "Target architecture")
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO)

# ==================== Defines ====================
add_definitions(
    -DENABLE_JIT=1
    -DARCH_ARM64=1
    -DUNIX_POSIX=1
    -D__APPLE__=1
    -DAPPLE=1
)

# Disable features not available on iOS
set(USE_NATIVE_INSTRUCTIONS OFF CACHE BOOL "" FORCE)
set(USE_VULKAN OFF CACHE BOOL "" FORCE)
set(USE_FAUDIO OFF CACHE BOOL "" FORCE)
set(USE_SDL OFF CACHE BOOL "" FORCE)
set(USE_LIBEVDEV OFF CACHE BOOL "" FORCE)
set(USE_LIBUSB OFF CACHE BOOL "" FORCE)
set(USE_ALSA OFF CACHE BOOL "" FORCE)
set(USE_PULSE OFF CACHE BOOL "" FORCE)
set(USE_WOLFSSL OFF CACHE BOOL "" FORCE)
set(USE_OPENAL OFF CACHE BOOL "" FORCE)
set(USE_CUBEB OFF CACHE BOOL "" FORCE)
set(USE_GLLD OFF CACHE BOOL "" FORCE)
set(USE_FFMPEG OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_GLSLANG OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_FFMPEG OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_LIBUSB OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_CURL OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_ZLIB OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_ZSTD OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_LIBPNG OFF CACHE BOOL "" FORCE)
set(USE_LIBUPNP OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_FFTW OFF CACHE BOOL "" FORCE)
set(USE_LLVM OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_LIBLZMA OFF CACHE BOOL "" FORCE)
set(BUILD_LLVM OFF CACHE BOOL "" FORCE)
set(USE_SYSTEM_BOOST OFF CACHE BOOL "" FORCE)
set(USE_VULKAN_MEM_ALLOC OFF CACHE BOOL "" FORCE)

# ==================== Compiler Options ====================
add_compile_options(
    -march=armv8-a
    -stdlib=libc++
    -Wno-multichar
    -Wno-ignored-pragmas
    -Wno-attributes
    -Wno-missing-field-initializers
    -Wno-sign-compare
    -Wno-unused-parameter
    -Wno-old-style-cast
    -Wno-availability
    -Wno-deprecated-declarations
    -Wno-unguarded-availability-new
    -Wno-error=return-type
    -Wno-error=old-style-cast
    -Wno-error=sign-compare
    -Wno-error=reorder
    -Wno-error=overloaded-virtual
    -Wno-error=missing-noreturn
    -Wno-error=implicit-fallthrough
)

# ==================== Source Paths ====================
set(APS3E_CPP "${CMAKE_CURRENT_SOURCE_DIR}/aps3e-extracted/aps3e-2.40/app/src/main/cpp")
set(RPCS3_DIR "${APS3E_CPP}/rpcs3")
set(RPCS3_SRC "${RPCS3_DIR}/rpcs3")
set(RPCS3_3RD "${RPCS3_DIR}/3rdparty")

# ==================== Stub Headers ====================
# Create stub headers for missing dependencies at configure time
set(STUB_DIR "${CMAKE_BINARY_DIR}/stubs")
file(MAKE_DIRECTORY "${STUB_DIR}/libavutil" "${STUB_DIR}/libavcodec" "${STUB_DIR}/libavformat"
     "${STUB_DIR}/libswscale" "${STUB_DIR}/libswresample" "${STUB_DIR}/libusb-1.0")

# FFmpeg stubs
file(WRITE "${STUB_DIR}/libavutil/pixfmt.h"
"#pragma once\nenum AVPixelFormat { AV_PIX_FMT_NONE=-1, AV_PIX_FMT_YUV420P=0, AV_PIX_FMT_YUYV422=1, AV_PIX_FMT_RGB24=2, AV_PIX_FMT_BGR24=3, AV_PIX_FMT_RGBA=26, AV_PIX_FMT_BGRA=28 };\n")

file(WRITE "${STUB_DIR}/libavutil/imgutils.h"
"#pragma once\n#include <stdint.h>\nstatic inline int av_image_fill_linesizes(int a[],int b,int c,int d){(void)a;(void)b;(void)c;(void)d;return 0;}\nstatic inline int av_image_fill_pointers(uint8_t *a[],int b,int c,uint8_t *d,const int e[]){(void)a;(void)b;(void)c;(void)d;(void)e;return 0;}\n")

file(WRITE "${STUB_DIR}/libswscale/swscale.h"
"#pragma once\n#include <stdint.h>\ntypedef void SwsContext;\nenum { SWS_FAST_BILINEAR=1, SWS_BILINEAR=2, SWS_BICUBIC=4, SWS_POINT=8 };\nstatic inline SwsContext* sws_getContext(int a,int b,int c,int d,int e,int f,int g,void *h,void *i,void *j){(void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)g;(void)h;(void)i;(void)j;return 0;}\nstatic inline SwsContext* sws_getCachedContext(SwsContext *c,int a,int b,int d,int e,int f,int g,int h,void *i,void *j,void *k){(void)c;(void)a;(void)b;(void)d;(void)e;(void)f;(void)g;(void)h;(void)i;(void)j;(void)k;return 0;}\nstatic inline int sws_scale(SwsContext *c,const uint8_t *const a[],const int b[],int d,int e,uint8_t *const f[],const int g[]){(void)c;(void)a;(void)b;(void)d;(void)e;(void)f;(void)g;return 0;}\nstatic inline void sws_freeContext(SwsContext *c){(void)c;}\n")

# libusb stub
file(WRITE "${STUB_DIR}/libusb-1.0/libusb.h"
"#pragma once\nstruct libusb_context;\nstruct libusb_device;\nstruct libusb_device_handle;\nstruct libusb_device_descriptor { unsigned short idVendor; unsigned short idProduct; unsigned char bNumConfigurations; };\nstruct libusb_config_descriptor { unsigned short wTotalLength; unsigned char bNumInterfaces; };\nstruct libusb_interface { unsigned char num_altsetting; };\nenum libusb_error { LIBUSB_SUCCESS=0, LIBUSB_ERROR_IO=-1 };\nstatic inline int libusb_init(void **c){(void)c;return 0;}\nstatic inline void libusb_exit(void *c){(void)c;}\nstatic inline int libusb_get_device_list(void *c,void **l){(void)c;(void)l;return 0;}\nstatic inline void libusb_free_device_list(void **l,int u){(void)l;(void)u;}\nstatic inline int libusb_get_device_descriptor(void *d,void *dd){(void)d;(void)dd;return 0;}\nstatic inline int libusb_get_config_descriptor(void *d,int i,void **cd){(void)d;(void)i;(void)cd;return 0;}\nstatic inline void libusb_free_config_descriptor(void *cd){(void)cd;}\nstatic inline int libusb_open(void *d,void **dh){(void)d;(void)dh;return 0;}\nstatic inline void libusb_close(void *dh){(void)dh;}\nstatic inline int libusb_claim_interface(void *dh,int i){(void)dh;(void)i;return 0;}\nstatic inline int libusb_release_interface(void *dh,int i){(void)dh;(void)i;return 0;}\n")

# OpenAL stubs
file(WRITE "${STUB_DIR}/al.h"
"#pragma once\ntypedef int ALenum;\ntypedef int ALint;\ntypedef unsigned int ALuint;\ntypedef int ALsizei;\ntypedef unsigned char ALboolean;\ntypedef float ALfloat;\ntypedef void ALvoid;\ntypedef unsigned char ALubyte;\n#define AL_TRUE 1\n#define AL_FALSE 0\n#define AL_NO_ERROR 0\nstatic inline void alGenSources(ALsizei n,ALuint *s){(void)n;(void)s;}\nstatic inline void alDeleteSources(ALsizei n,const ALuint *s){(void)n;(void)s;}\nstatic inline void alSourcei(ALuint s,ALenum p,ALint v){(void)s;(void)p;(void)v;}\nstatic inline void alSourcef(ALuint s,ALenum p,ALfloat v){(void)s;(void)p;(void)v;}\nstatic inline void alSourcePlay(ALuint s){(void)s;}\nstatic inline void alSourcePause(ALuint s){(void)s;}\nstatic inline void alSourceStop(ALuint s){(void)s;}\nstatic inline void alGetSourcei(ALuint s,ALenum p,ALint *v){(void)s;(void)p;(void)v;}\nstatic inline void alGenBuffers(ALsizei n,ALuint *b){(void)n;(void)b;}\nstatic inline void alDeleteBuffers(ALsizei n,const ALuint *b){(void)n;(void)b;}\nstatic inline void alBufferData(ALuint b,ALenum f,const ALvoid *d,ALsizei s,ALsizei r){(void)b;(void)f;(void)d;(void)s;(void)r;}\nstatic inline void alGetBufferi(ALuint b,ALenum p,ALint *v){(void)b;(void)p;(void)v;}\nstatic inline void alListeneri(ALenum p,ALint v){(void)p;(void)v;}\nstatic inline void alListenerf(ALenum p,ALfloat v){(void)p;(void)v;}\nstatic inline void alListenerfv(ALenum p,const ALfloat *v){(void)p;(void)v;}\nstatic inline ALenum alGetError(void){return 0;}\nstatic inline ALboolean alIsExtensionPresent(ALubyte *e){(void)e;return 0;}\nstatic inline void* alGetProcAddress(ALubyte *n){(void)n;return 0;}\n")

file(WRITE "${STUB_DIR}/alc.h"
"#pragma once\ntypedef void ALCdevice;\ntypedef void ALCcontext;\ntypedef int ALCenum;\ntypedef int ALCint;\ntypedef unsigned int ALCuint;\ntypedef int ALCsizei;\ntypedef unsigned char ALCboolean;\ntypedef const char* ALCstring;\n#define ALC_TRUE 1\n#define ALC_FALSE 0\n#define ALC_NO_ERROR 0\nstatic inline ALCdevice* alcOpenDevice(ALCstring d){(void)d;return 0;}\nstatic inline ALCboolean alcCloseDevice(ALCdevice *d){(void)d;return 1;}\nstatic inline ALCcontext* alcCreateContext(ALCdevice *d,const ALCint *a){(void)d;(void)a;return 0;}\nstatic inline ALCboolean alcMakeContextCurrent(ALCcontext *c){(void)c;return 1;}\nstatic inline void alcDestroyContext(ALCcontext *c){(void)c;}\nstatic inline ALCenum alcGetError(ALCdevice *d){(void)d;return 0;}\nstatic inline ALCboolean alcIsExtensionPresent(ALCdevice *d,ALCstring e){(void)d;(void)e;return 0;}\nstatic inline void* alcGetProcAddress(ALCdevice *d,ALCstring n){(void)d;(void)n;return 0;}\nstatic inline void alcGetIntegerv(ALCdevice *d,ALCenum p,ALCsizei s,ALCint *v){(void)d;(void)p;(void)s;(void)v;}\nstatic inline ALCstring alcGetString(ALCdevice *d,ALCenum p){(void)d;(void)p;return \"\";}\nstatic inline ALCdevice* alcCaptureOpenDevice(ALCstring d,ALCuint f,ALCenum fmt,ALCsizei sz){(void)d;(void)f;(void)fmt;(void)sz;return 0;}\n")

file(WRITE "${STUB_DIR}/rtmidi_c.h"
"#pragma once\ntypedef void RtMidiPtr;\ntypedef void RtMidiInPtr;\ntypedef void RtMidiOutPtr;\nstatic inline RtMidiInPtr rtmidi_in_create_default(void){return 0;}\nstatic inline void rtmidi_in_open_port(RtMidiInPtr i,unsigned int p,const char *n){(void)i;(void)p;(void)n;}\nstatic inline void rtmidi_in_close_port(RtMidiInPtr i){(void)i;}\n")

# pthread availability wrapper
file(WRITE "${STUB_DIR}/pthread.h"
"#pragma once\n#include <Availability.h>\n#undef __API_UNAVAILABLE\n#define __API_UNAVAILABLE(...)\n#undef __API_UNAVAILABLE_MSG\n#define __API_UNAVAILABLE_MSG(...)\n#include_next <pthread.h>\n")

message(STATUS "Created stub headers in ${STUB_DIR}")

# ==================== Add include paths for stubs ====================
include_directories(BEFORE "${STUB_DIR}")

# ==================== Build rpcs3 core ====================
add_subdirectory("${RPCS3_DIR}" EXCLUDE_FROM_ALL)

# ==================== Ps3Dream Native Library ====================
add_library(ps3dream_native STATIC
    # Bridge (Objective-C++ - heart of the port)
    Ps3Dream/Bridge/Ps3DreamBridge.mm

    # Platform layer
    Ps3Dream/Platform/ios_window.cpp
    Ps3Dream/Platform/ios_cpuinfo.cpp
    Ps3Dream/Platform/ios_meminfo.cpp

    # JIT support
    Ps3Dream/JIT/ios_jit.cpp

    # MoltenVK integration
    Ps3Dream/MoltenVK/ios_mvk.cpp

    # APS3E bridge sources (Android -> iOS adapted)
    ${APS3E_CPP}/emulator.cpp
    ${APS3E_CPP}/emulator_aps3e.cpp
    ${APS3E_CPP}/aps3e.cpp
    ${APS3E_CPP}/aps3e_emu.cpp
    ${APS3E_CPP}/vkapi.cpp
    ${APS3E_CPP}/vkutil.cpp
    ${APS3E_CPP}/cpuinfo.cpp
    ${APS3E_CPP}/glsl2spv.cpp
    ${APS3E_CPP}/meminfo.cpp
    ${APS3E_CPP}/aps3e_rp3_impl.cpp

    # RPCS3 sources needed by the bridge
    ${RPCS3_SRC}/Input/raw_mouse_config.cpp
    ${RPCS3_SRC}/Input/raw_mouse_handler.cpp
    ${RPCS3_SRC}/Input/product_info.cpp
    ${RPCS3_SRC}/rpcs3_version.cpp
    ${RPCS3_SRC}/stdafx.cpp
)

target_include_directories(ps3dream_native PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/Platform
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/JIT
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/MoltenVK
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/Bridge
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream
    ${APS3E_CPP}
    ${RPCS3_DIR}
    ${RPCS3_SRC}
    ${RPCS3_3RD}
)

target_link_libraries(ps3dream_native PRIVATE
    rpcs3_emu
)

# Apple frameworks
find_library(METAL_FRAMEWORK Metal)
find_library(QUARTZ_CORE QuartzCore)
find_library(UIKIT UIKit)
find_library(FOUNDATION Foundation)
find_library(CORE_GRAPHICS CoreGraphics)
find_library(IOKIT IOKit)
find_library(CORE_FOUNDATION CoreFoundation)
find_library(SECURITY Security)
find_library(CORE_VIDEO CoreVideo)

target_link_libraries(ps3dream_native PRIVATE
    ${METAL_FRAMEWORK}
    ${QUARTZ_CORE}
    ${UIKIT}
    ${FOUNDATION}
    ${CORE_GRAPHICS}
    ${IOKIT}
    ${CORE_FOUNDATION}
    ${SECURITY}
    ${CORE_VIDEO}
    pthread
    dl
)

# MoltenVK
option(MVK_PATH "Path to MoltenVK SDK" "")
if(MVK_PATH)
    set(MVK_LIB "${MVK_PATH}/MoltenVK/MoltenVK.xcframework/ios-arm64/libMoltenVK.a")
    if(EXISTS "${MVK_LIB}")
        target_link_libraries(ps3dream_native PRIVATE "${MVK_LIB}")
    endif()
    target_include_directories(ps3dream_native PRIVATE "${MVK_PATH}/MoltenVK/include")
endif()
