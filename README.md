<div align="center">

# Ps3Dream

### PlayStation 3 Emulator for iOS

[![Build](https://github.com/modey219/Ps3Dream/actions/workflows/build.yml/badge.svg)](https://github.com/modey219/Ps3Dream/actions/workflows/build.yml)
![Platform](https://img.shields.io/badge/platform-iOS%2017.0+-blue)
![Architecture](https://img.shields.io/badge/architecture-ARM64-orange)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

<br/>

*Run PS3 games on your iPhone or iPad — powered by the [RPCS3](https://rpcs3.net) emulator core.*

</div>

---

## Overview

Ps3Dream is an iOS port of the RPCS3 PlayStation 3 emulator. It compiles the entire RPCs3 core for iOS ARM64, translates Vulkan rendering to Metal via MoltenVK, and provides a native Swift/UIKit interface for game management, touch controls, and settings.

| Component | Implementation |
|-----------|---------------|
| **Emulation Core** | RPCS3 PPU/SPU LLVM recompilers (ARM64 native) |
| **Graphics** | Vulkan → MoltenVK → Metal |
| **Input** | Touch overlay (VirtualPadOverlay) mapped to RPCS3 pad system |
| **Audio** | Cubeb cross-platform backend |
| **UI** | Swift/UIKit — game browser, settings, firmware install |
| **Bridge** | Objective-C++ (`Ps3DreamBridge.mm`) replacing Android JNI |

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│  Swift / UIKit                                 │
│  ┌───────────┐ ┌──────────┐ ┌───────────────┐  │
│  │ GameList  │ │ Emulator │ │ VirtualPad    │  │
│  │ ViewCtrl  │ │ ViewCtrl │ │ Overlay       │  │
│  └─────┬─────┘ └────┬─────┘ └──────┬────────┘  │
│        │             │              │            │
│  ┌─────┴─────────────┴──────────────┴────────┐  │
│  │         EmulatorManager.swift             │  │
│  └─────────────────────┬─────────────────────┘  │
├────────────────────────┼────────────────────────┤
│  Objective-C++ Bridge  │                        │
│  ┌─────────────────────┴─────────────────────┐  │
│  │         Ps3DreamBridge.mm                 │  │
│  └─────────────────────┬─────────────────────┘  │
├────────────────────────┼────────────────────────┤
│  C++ / RPCS3 Core                            │
│  ┌───────────┐ ┌───────┴──────┐ ┌───────────┐  │
│  │ Emu/Cell  │ │ Emu/RSX/VK  │ │ Input/    │  │
│  │ PPU/SPU   │ │ VKGSRender  │ │ pad_thread│  │
│  └─────┬─────┘ └──────┬──────┘ └─────┬─────┘  │
│        │               │              │         │
│  ┌─────┴───────────────┴──────────────┴──────┐  │
│  │              librpcs3_emu.a               │  │
│  └───────────────────┬───────────────────────┘  │
├──────────────────────┼──────────────────────────┤
│  Platform Layer                           │
│  ┌────────┐ ┌────────┐ ┌───────┐ ┌──────┐│  │
│  │ MoltenVK│ │ JIT    │ │ Window│ │ Metal││  │
│  │ iOS_MVK │ │ csops  │ │ CAML  │ │ stub ││  │
│  └────────┘ └────────┘ └───────┘ └──────┘│  │
└─────────────────────────────────────────────────┘
```

---

## Features

- **Game Library** — Scan folders for PS3 games; reads PARAM.SFO titles and icons
- **Firmware & PKG Install** — Import PS3 PUP firmware and PKG packages
- **Touch Controller** — Full virtual pad overlay with D-pad, face buttons, triggers, analog sticks
- **Renderer Selection** — Vulkan (via MoltenVK) or Null renderer
- **Resolution Scaling** — 480p to 1080p with upscaling
- **FPS Counter** — Optional frame rate overlay
- **Screenshots** — Capture and save to Photos
- **Persistent Settings** — Renderer, audio, resolution, input opacity via UserDefaults

---

## Project Structure

```
ps3dream-ios/
├── .github/workflows/build.yml    # CI pipeline (macOS-14, Xcode 15.4)
├── CMakeLists.txt                  # iOS CMake build system
├── Ps3Dream/
│   ├── Bridge/
│   │   ├── Ps3DreamBridge.h        # C API header
│   │   └── Ps3DreamBridge.mm       # Obj-C++ bridge (replaces JNI)
│   ├── Emulator/
│   │   ├── EmulatorManager.swift   # Emulator lifecycle
│   │   └── AppSettings.swift       # UserDefaults config
│   ├── Platform/
│   │   ├── ios_window.cpp          # CAMetalLayer ↔ ANativeWindow
│   │   ├── ios_cpuinfo.cpp         # CPU detection (ARM64)
│   │   ├── ios_meminfo.cpp         # Memory info (mach API)
│   │   ├── ios_link_stub.cpp       # Link-time symbol stubs
│   │   ├── ios_jit_stub.cpp        # JIT enable stub
│   │   └── ios_metal_stub.cpp      # Metal layer stub
│   ├── JIT/
│   │   └── ios_jit.cpp             # csops() JIT activation
│   ├── MoltenVK/
│   │   └── ios_mvk.cpp             # Vulkan → Metal
│   ├── UI/
│   │   ├── GameListViewController.swift
│   │   ├── EmulatorViewController.swift
│   │   ├── VirtualPadOverlay.swift
│   │   ├── SettingsViewController.swift
│   │   └── GameCell.swift
│   └── Swift/
│       ├── Ps3DreamApp.swift       # App entry point
│       └── Assets.xcassets/
├── rpcs3_build/                    # Cloned RPCS3 core (pinned)
└── build_ios.sh                    # Local build script
```

---

## Build

### CI (Recommended)

Push to `main` — GitHub Actions builds the full IPA automatically:

1. Clones RPCS3 core at pinned commit
2. Cross-compiles LLVM for iOS ARM64
3. Builds `librpcs3_emu.a` (1164+ translation units)
4. Compiles 3rdparty libs (asmjit, yaml-cpp, SoundTouch, glslang, SPIRV, etc.)
5. Links everything with the Swift app into an IPA artifact

Download the `.ipa` from [Actions → latest run → Artifacts](https://github.com/modey219/Ps3Dream/actions).

### Local Build (macOS)

```bash
# Requirements: macOS with Xcode 15+, iOS SDK 17.0+

# 1. Build MoltenVK
git clone https://github.com/KhronosGroup/MoltenVK.git
cd MoltenVK && make && cd ..

# 2. Clone RPCS3 core
git clone --depth 1 --recursive https://github.com/RPCS3/rpcs3.git

# 3. Build Ps3Dream
cd ps3dream-ios
chmod +x build_ios.sh
./build_ios.sh /path/to/MoltenVK

# 4. Open in Xcode
open build-ios/Ps3Dream.xcodeproj
```

---

## Requirements

| Requirement | Details |
|-------------|---------|
| **Device** | iPhone or iPad with ARM64 (A12+) |
| **OS** | iOS 17.0 or later |
| **Developer Mode** | Settings → Privacy & Security → Developer Mode (ON) |
| **PS3 Firmware** | PUP file (v4.91) — install via the app |
| **Storage** | 2 GB+ free (emulator + games) |

---

## How It Works

### JIT Compilation

RPCS3 recompiles PS3 PPU and SPU bytecode to native ARM64 instructions at runtime. This requires **Write XOR Execute** memory pages, which iOS restricts by default. Developer Mode + `csops(CS_DEBUGGED)` enables JIT:

```c
// ios_jit.cpp
int cs_op = CS_OPS_STATUS;
cs_ops(NULL, &cs_op, ...);  // Enable debug flag
mprotect(addr, len, PROT_READ | PROT_WRITE | PROT_EXEC);
```

### MoltenVK Rendering Pipeline

```
RPCS3 VKGSRender → Vulkan API → MoltenVK → Metal API → CAMetalLayer
```

MoltenVK intercepts all Vulkan calls and translates them to Metal equivalents. The `swapchain_macos.hpp` is patched to use `CAMetalLayer` on iOS.

### Bridge Layer

`Ps3DreamBridge.mm` implements the C API that Swift calls via bridging header. It manages the RPCS3 emulator lifecycle:

- **Boot**: `Emu.BootGame()` / `Emu.BootISO()`
- **Render**: Creates `VKGSRender` with MoltenVK
- **Input**: Routes touch events through `pad_thread`
- **Audio**: Cubeb backend for cross-platform audio

### Touch Input

`VirtualPadOverlay` renders a transparent touch layer over the Metal view. Touch events are mapped to RPCS3 pad buttons (cross, circle, square, triangle, D-pad, triggers, analog sticks) and fed into the emulator via `pad_thread`.

---

## Key Differences from Desktop RPCS3

| Feature | Desktop RPCS3 | Ps3Dream iOS |
|---------|--------------|--------------|
| GPU API | Direct Vulkan | Vulkan → MoltenVK → Metal |
| JIT | OS-native JIT | `csops()` + Developer Mode |
| UI | Qt widgets | Swift/UIKit |
| Input | Keyboard/controller | Touch overlay |
| Memory | ~8 GB+ | ~4 GB (iOS limit) |
| Compiler | Host toolchain | Cross-compile for iOS ARM64 |
| Audio | Cubeb/ALSA/WASAPI | Cubeb (AudioToolbox) |

---

## Limitations

- **Performance** — Mobile ARM64 is slower than desktop x86_64 for PS3 emulation
- **Memory** — iOS apps are limited to ~4-6 GB; some PS3 games require more
- **Compatibility** — Many games still need RSX-specific fixes
- **Thermal** — Extended play will cause thermal throttling
- **Dialogs** — Message dialogs and on-screen keyboard auto-dismiss (stubs)

---

## Credits

| Project | Role | License |
|---------|------|---------|
| [RPCS3](https://rpcs3.net) | PS3 emulator core | GPL-2.0 |
| [MoltenVK](https://github.com/KhronosGroup/MoltenVK) | Vulkan → Metal | Apache-2.0 |
| [Cubeb](https://github.com/mozilla/cubeb) | Cross-platform audio | ISC |
| [asmjit](https://asmjit.com) | JIT assembler | Zlib |
| [yaml-cpp](https://github.com/jbeder/yaml-cpp) | YAML parser | MIT |
| [glslang](https://github.com/KhronosGroup/glslang) | GLSL → SPIR-V | Apache-2.0 |
| [SoundTouch](https://www.surina.net/soundtouch/) | Audio resampling | LGPL-2.1 |
| [VulkanMemoryAllocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator) | GPU memory | MIT |

---

## License

This project is licensed under the GNU General Public License v3.0 — see the [LICENSE](LICENSE) file for details.

PS3Dream incorporates code from RPCS3 (GPL-2.0) and other open-source projects. All original licenses are respected.
