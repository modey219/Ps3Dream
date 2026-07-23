# Ps3Dream iOS - CMake Build System
# Cross-compilation for iOS (arm64) with MoltenVK and JIT support
#
# Usage:
#   mkdir build-ios && cd build-ios
#   cmake .. -G Xcode -DCMAKE_SYSTEM_NAME=iOS \
#     -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
#     -DCMAKE_OSX_ARCHITECTURES=arm64 \
#     -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
#     -DMVK_PATH=/path/to/MoltenVK
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

# Enable JIT: requires Developer Mode on device
add_definitions(-DENABLE_JIT=1)

# RPCS3 defines
add_definitions(-DARCH_ARM64=1)
add_definitions(-DUNIX_POSIX=1)
add_definitions(-D__APPLE__=1)
add_definitions(-DAPPLE=1)

# Compiler options
add_compile_options(-march=armv8-a)
add_compile_options(-stdlib=libc++)
add_compile_options(-fno-rtti)
add_compile_options(-Wno-multichar)
add_compile_options(-Wno-ignored-pragmas)
add_compile_options(-Wno-attributes)
add_compile_options(-Wno-missing-field-initializers)
add_compile_options(-Wno-sign-compare)
add_compile_options(-Wno-unused-parameter)
add_compile_options(-Wno-old-style-cast)

# ==================== MoltenVK ====================
# Download MoltenVK from: https://github.com/KhronosGroup/MoltenVK/releases
# Or build from source: https://github.com/KhronosGroup/MoltenVK

option(MVK_PATH "Path to MoltenVK SDK" "")

if(MVK_PATH)
    set(MVK_INCLUDE_DIR "${MVK_PATH}/MoltenVK/include" CACHE PATH "MoltenVK include dir")
    set(MVK_LIBRARY "${MVK_PATH}/MoltenVK/MoltenVK.xcframework/ios-arm64/libMoltenVK.a" CACHE FILEPATH "MoltenVK static lib")
else()
    # Fallback: will be linked as framework
    find_library(MVK_FRAMEWORK MoltenVK)
endif()

# ==================== Third-party Dependencies ====================

# rpcs3 3rdparty directory
set(RPCS3_3RDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/rpcs3/3rdparty")

# yaml-cpp
add_library(yaml-cpp STATIC
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/collectionstack.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/collectionreader.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/convert.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/depth.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/directives.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/emit.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/emitfromevents.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/emittermanip.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/event.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/eventhandler.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/exceptions.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/exp.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/indentation.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/node.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/nodebuilder.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/nodeevents.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/null.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/ostream_wrapper.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/parse.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/parser.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/regex.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/scanner.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/scanscalar.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/scantag.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/scantoken.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/simplekey.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/singledocparser.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/stream.cpp
    ${RPCS3_3RDPARTY_DIR}/yaml-cpp/src/tag.cpp
)
target_include_directories(yaml-cpp PUBLIC ${RPCS3_3RDPARTY_DIR}/yaml-cpp/include)

# glslang (for PPU cache pre-compilation)
add_subdirectory(${RPCS3_3RDPARTY_DIR}/glslang EXCLUDE_FROM_ALL)

# ==================== RPCS3 Core ====================
# Add the rpcs3 emulator core as a static library
# This includes: Cell processor emulation (PPU/SPU), RSX (GPU), Filesystem, etc.
add_subdirectory(rpcs3 EXCLUDE_FROM_ALL)

# ==================== Ps3Dream iOS Native Library ====================
add_library(ps3dream_native SHARED
    # iOS Platform Layer
    Ps3Dream/Platform/ios_window.cpp

    # JIT Support
    Ps3Dream/JIT/ios_jit.cpp

    # MoltenVK Integration
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/MoltenVK/ios_mvk.cpp

    # Emulator Bridge (Objective-C++)
    Ps3Dream/Bridge/Ps3DreamBridge.mm
)

target_include_directories(ps3dream_native PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/rpcs3
    ${CMAKE_CURRENT_SOURCE_DIR}/rpcs3/rpcs3
    ${CMAKE_CURRENT_SOURCE_DIR}/rpcs3/3rdparty
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/Platform
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/JIT
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/MoltenVK
    ${CMAKE_CURRENT_SOURCE_DIR}/Ps3Dream/Bridge
)

if(MVK_INCLUDE_DIR)
    target_include_directories(ps3dream_native PRIVATE ${MVK_INCLUDE_DIR})
endif()

target_link_libraries(ps3dream_native PRIVATE
    rpcs3_emu
    3rdparty::yaml-cpp
    3rdparty::glslang
)

# Link MoltenVK
if(MVK_LIBRARY)
    target_link_libraries(ps3dream_native PRIVATE ${MVK_LIBRARY})
elseif(MVK_FRAMEWORK)
    target_link_libraries(ps3dream_native PRIVATE ${MVK_FRAMEWORK})
endif()

# Apple frameworks
find_library(METAL_FRAMEWORK Metal)
find_library(QUARTZ_CORE QuartzCore)
find_library(UIKIT UIKit)
find_library(FOUNDATION Foundation)
find_library(CORE_GRAPHICS CoreGraphics)
find_library(IOKIT IOKit)
find_library(CORE_FOUNDATION CoreFoundation)
find_library(SECURITY Security)

target_link_libraries(ps3dream_native PRIVATE
    ${METAL_FRAMEWORK}
    ${QUARTZ_CORE}
    ${UIKIT}
    ${FOUNDATION}
    ${CORE_GRAPHICS}
    ${IOKIT}
    ${CORE_FOUNDATION}
    ${SECURITY}
    pthread
    dl
)

# ==================== Xcode App Target ====================
# This sets up the iOS app bundle structure

set(APP_SOURCES
    Ps3Dream/Ps3DreamApp.swift
    Ps3Dream/UI/GameListViewController.swift
    Ps3Dream/UI/GameCell.swift
    Ps3Dream/UI/EmulatorViewController.swift
    Ps3Dream/UI/VirtualPadOverlay.swift
    Ps3Dream/UI/SettingsViewController.swift
)

# Note: The actual Xcode project (.xcodeproj) must be generated
# via: cmake -G Xcode ...
# or manually created in Xcode and linked to these files.
#
# For a manual Xcode setup, create an iOS App target with:
# - Swift sources from Ps3Dream/UI/
# - ObjC++ bridge from Ps3Dream/Bridge/
# - C++ native lib linked
# - Deployment target: iOS 17.0
# - Architectures: arm64
# - Signing: Personal team (for JIT via CS_DEBUGGED)
