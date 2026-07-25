# Ps3Dream iOS

PS3 Emulator for iOS - Ported from [APS3E](https://github.com/nicegram/APS3E) (Android) using [RPCS3](https://github.com/RPCS3/rpcs3) core.

## Architecture

```
ps3dream-ios/
├── CMakeLists.txt                    # iOS CMake build system
├── build_ios.sh                      # Build script for macOS
├── Ps3Dream/
│   ├── Ps3DreamApp.swift             # App entry point
│   ├── Info.plist                    # iOS app configuration
│   ├── Ps3Dream.entitlements         # JIT & sandbox entitlements
│   ├── ps3dream_emulator.hpp         # RPCS3 include umbrella
│   ├── Ps3Dream-Bridging-Header.h    # C/C++ ↔ Swift bridge
│   ├── Bridge/
│   │   ├── Ps3DreamBridge.h          # C API header (replaces JNI)
│   │   └── Ps3DreamBridge.mm         # Obj-C++ bridge implementation
│   ├── Emulator/
│   │   ├── EmulatorManager.swift     # Emulator lifecycle manager
│   │   └── AppSettings.swift         # Persistent settings (UserDefaults)
│   ├── Platform/
│   │   ├── ios_platform.h            # Platform abstraction
│   │   ├── ios_window.h/.cpp         # CAMetalLayer ↔ ANativeWindow
│   │   ├── ios_log.h                 # os_log ↔ __android_log
│   │   ├── ios_mmap.h                # Memory mapping
│   │   ├── ios_cpuinfo.cpp           # CPU detection (ARM64 features)
│   │   └── ios_meminfo.cpp           # Memory info (mach API)
│   ├── JIT/
│   │   └── ios_jit.h/.cpp            # JIT enable (csops/mprotect)
│   ├── MoltenVK/
│   │   └── ios_mvk.h/.cpp            # Vulkan → Metal via MoltenVK
│   ├── UI/
│   │   ├── GameListViewController.swift   # Game browser + firmware install
│   │   ├── GameCell.swift                 # Game list cell
│   │   ├── EmulatorViewController.swift   # Emulation screen
│   │   ├── VirtualPadOverlay.swift        # Touch controller
│   │   └── SettingsViewController.swift   # Settings with persistence
│   └── Assets.xcassets/              # App icons & images
├── aps3e-extracted/                   # APS3E source (Android bridge + RPCS3)
│   └── aps3e-2.40/app/src/main/cpp/
│       ├── *.cpp                     # Android bridge sources
│       └── rpcs3/                    # RPCS3 emulator core + 3rdparty
└── .github/workflows/build.yml       # GitHub Actions CI pipeline
```

## Key Differences from Android Version

| Component | Android (APS3E) | iOS (Ps3Dream) |
|-----------|-----------------|----------------|
| **Bridge** | JNI (`JNIEnv*`) | Objective-C++ (`Ps3DreamBridge.mm`) |
| **Surface** | `ANativeWindow` | `CAMetalLayer` (Metal) |
| **Vulkan** | `dlopen("libvulkan.so")` | MoltenVK (Vulkan→Metal) |
| **JIT** | Automatic (Linux) | `csops()` + Developer Mode |
| **Logging** | `__android_log_print` | `os_log` |
| **UI** | Java/Android XML | Swift/UIKit |
| **Input** | `AndroidVirtualPadHandler` | `VirtualPadOverlay` (touch) |
| **Threading** | Linux pthreads | Apple pthreads + Grand Central |
| **Settings** | YAML config file | UserDefaults persistence |

## Requirements

- **macOS** with Xcode 15+ (for local build) or **GitHub Actions** (no Mac needed)
- **iOS 17.0+** device (Developer Mode enabled)
- **MoltenVK SDK** ([download](https://github.com/KhronosGroup/MoltenVK/releases))
- **PS3 Firmware** (PUP file, 4.91)

## Build Instructions

### Option 1: GitHub Actions (No Mac needed)
See [BUILD_INSTRUCTIONS_AR.md](BUILD_INSTRUCTIONS_AR.md) for Arabic guide.

### Option 2: Local Build on macOS
```bash
# 1. Clone/download MoltenVK
git clone https://github.com/KhronosGroup/MoltenVK.git
cd MoltenVK && make

# 2. Clone rpcs3 for reference
git clone --depth 1 --recursive https://github.com/RPCS3/rpcs3.git

# 3. Build Ps3Dream
cd ps3dream-ios
chmod +x build_ios.sh
./build_ios.sh /path/to/MoltenVK

# 4. Open in Xcode and deploy
open build-ios/Ps3Dream.xcodeproj
```

## Enable JIT on iOS

JIT compilation is **required** for PPU/SPU recompilers. On iOS 17+:

1. Go to **Settings > Privacy & Security > Developer Mode**
2. Turn **Developer Mode ON**
3. Restart the app
4. JIT will be enabled automatically via `csops(CS_DEBUGGED)`

## How It Works

### Bridge Layer (`Ps3DreamBridge.mm`)
The Objective-C++ bridge replaces all JNI calls from the Android version:
- **Config**: YAML parsing via yaml-cpp (same as Android)
- **Boot**: `Emu.BootGame()` / `Emu.BootISO()` (same RPCS3 core)
- **Render**: `VKGSRender` via MoltenVK (Vulkan→Metal)
- **Input**: Virtual pad → `pad_thread` → RPCS3 input system
- **Audio**: Cubeb backend (cross-platform)

### Emulator Manager (`EmulatorManager.swift`)
Manages the emulator lifecycle from Swift:
- State observation (running/paused/stopped)
- Button/stick input mapping
- Firmware and PKG installation
- Thread-safe callbacks to UI

### App Settings (`AppSettings.swift`)
Persistent configuration via UserDefaults:
- Renderer selection (Vulkan/Null)
- Resolution scale (480p-1080p)
- Audio backend
- Virtual pad opacity
- FPS counter toggle

### MoltenVK Integration
MoltenVK translates Vulkan API calls to Metal:
1. RPCS3's `VKGSRender` calls Vulkan functions
2. MoltenVK intercepts and translates to Metal commands
3. Metal renders on the GPU via `CAMetalLayer`

### JIT Compilation
RPCS3 recompiles PS3 PPU/SPU code to ARM64 native code:
- PPU LLVM recompiler generates ARM64 machine code
- SPU ASMJIT/LLVM recompiler generates ARM64 code
- These require W^X (Write XOR Execute) memory pages
- iOS restricts this via code signing; Developer Mode relaxes it

## Features

- **Game Browser**: Scan folders for PS3 games, read PARAM.SFO titles
- **Firmware Install**: Import and install PS3 PUP firmware files
- **PKG Install**: Import and install PS3 PKG packages
- **Virtual Controller**: Full touch overlay with D-pad, face buttons, shoulders, analog sticks
- **Settings**: Configurable renderer, resolution, audio, input opacity
- **FPS Counter**: Optional frame rate display
- **Screenshot**: Capture and save screenshots to Photos

## Limitations

- **Performance**: Mobile ARM64 is slower than desktop x86_64 for PS3 emulation
- **Memory**: iOS apps are limited to ~4-6GB RAM; PS3 games may need more
- **Compatibility**: Many games still require specific RSX fixes
- **No Vulkan extensions**: Some advanced Vulkan features are missing on MoltenVK
- **Heat**: Extended play will cause thermal throttling
- **Dialog stubs**: Message dialogs and on-screen keyboard auto-dismiss

## Credits

- **RPCS3** - PlayStation 3 emulator (https://rpcs3.net)
- **APS3E** - Android port of RPCS3 by aenu
- **MoltenVK** - Vulkan to Metal translation layer (Khronos Group)
- **Cubeb** - Cross-platform audio library (Mozilla)
- **yaml-cpp** - YAML parser
- **glslang** - GLSL to SPIR-V compiler
