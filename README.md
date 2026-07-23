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
│   ├── Platform/
│   │   ├── ios_platform.h            # Platform abstraction
│   │   ├── ios_window.h/.cpp         # CAMetalLayer ↔ ANativeWindow
│   │   ├── ios_log.h                 # os_log ↔ __android_log
│   │   └── ios_mmap.h                # Memory mapping
│   ├── JIT/
│   │   ├── ios_jit.h/.cpp            # JIT enable (csops/mprotect)
│   ├── MoltenVK/
│   │   ├── ios_mvk.h/.cpp            # Vulkan → Metal via MoltenVK
│   ├── UI/
│   │   ├── GameListViewController.swift   # Game browser
│   │   ├── GameCell.swift                 # Game list cell
│   │   ├── EmulatorViewController.swift   # Emulation screen
│   │   ├── VirtualPadOverlay.swift        # Touch controller
│   │   └── SettingsViewController.swift   # Settings
│   └── Assets.xcassets/              # App icons & images
├── rpcs3/                            # RPCS3 core (from APS3E)
│   ├── rpcs3/                        # Emulator core (PPU, SPU, RSX, etc.)
│   └── 3rdparty/                     # yaml-cpp, glslang, ffmpeg, etc.
└── MoltenVK/                         # MoltenVK SDK (download separately)
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

## Requirements

- **macOS** with Xcode 15+
- **iOS 17.0+** device (Developer Mode enabled)
- **MoltenVK SDK** ([download](https://github.com/KhronosGroup/MoltenVK/releases))
- **PS3 Firmware** (PUP file, 4.91)

## Build Instructions

```bash
# 1. Clone/download MoltenVK
git clone https://github.com/KhronosGroup/MoltenVK.git
cd MoltenVK && make

# 2. Build Ps3Dream
cd ps3dream-ios
chmod +x build_ios.sh
./build_ios.sh /path/to/MoltenVK

# 3. Open in Xcode and deploy
open build-ios/Ps3Dream.xcodeproj
```

## Enable JIT on iOS

JIT compilation is **required** for PPU/SPU recompilers. On iOS 17+:

1. Go to **Settings > Privacy & Security > Developer Mode**
2. Turn **Developer Mode ON**
3. Restart the app
4. JIT will be enabled automatically via `csops(CS_DEBUGGED)`

For older iOS or non-developer accounts:
- Use a jailbroken device
- Or sign with an enterprise certificate that grants JIT entitlements

## How It Works

### Bridge Layer (`Ps3DreamBridge.mm`)
The Objective-C++ bridge replaces all JNI calls from the Android version:
- **Config**: YAML parsing via yaml-cpp (same as Android)
- **Boot**: `Emu.BootGame()` / `Emu.BootISO()` (same RPCS3 core)
- **Render**: `VKGSRender` via MoltenVK (Vulkan→Metal)
- **Input**: Virtual pad → `pad_thread` → RPCS3 input system
- **Audio**: Cubeb backend (cross-platform)

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

## Limitations

- **Performance**: Mobile ARM64 is slower than desktop x86_64 for PS3 emulation
- **Memory**: iOS apps are limited to ~4-6GB RAM; PS3 games may need more
- **Compatibility**: Many games still require specific RSX fixes
- **No Vulkan extensions**: Some advanced Vulkan features are missing on MoltenVK
- **Heat**: Extended play will cause thermal throttling

## Credits

- **RPCS3** - PlayStation 3 emulator (https://rpcs3.net)
- **APS3E** - Android port of RPCS3 by aenu
- **MoltenVK** - Vulkan to Metal translation layer (Khronos Group)
- **Cubeb** - Cross-platform audio library (Mozilla)
- **yaml-cpp** - YAML parser
- **glslang** - GLSL to SPIR-V compiler
