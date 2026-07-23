#!/bin/bash
# Ps3Dream iOS - Build Script
# This script sets up the iOS build environment and compiles the emulator
#
# Prerequisites:
#   - macOS with Xcode 15+ installed
#   - iOS SDK 17.0+
#   - CMake 3.22+
#   - MoltenVK SDK (download from GitHub releases)
#
# Usage:
#   ./build_ios.sh /path/to/MoltenVK

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build-ios"
MVK_PATH="${1:-${SCRIPT_DIR}/MoltenVK}"

echo "=========================================="
echo "  Ps3Dream iOS Build Script"
echo "=========================================="

# Check prerequisites
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake not found. Install via: brew install cmake"
    exit 1
fi

if ! xcodebuild -version &> /dev/null; then
    echo "ERROR: Xcode not found. Install from App Store."
    exit 1
fi

# Check MoltenVK
if [ ! -d "$MVK_PATH" ]; then
    echo "MoltenVK not found at: $MVK_PATH"
    echo "Download from: https://github.com/KhronosGroup/MoltenVK/releases"
    echo ""
    echo "  mkdir MoltenVK"
    echo "  cd MoltenVK"
    echo "  tar xzf MoltenVK-<version>.tar.xz"
    echo ""
    echo "Or build from source:"
    echo "  git clone https://github.com/KhronosGroup/MoltenVK.git"
    echo "  cd MoltenVK"
    echo "  make"
    exit 1
fi

echo "MoltenVK path: $MVK_PATH"
echo "Build directory: $BUILD_DIR"

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake for iOS cross-compilation
echo ""
echo ">>> Configuring CMake for iOS..."
cmake "$SCRIPT_DIR" \
    -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DMVK_PATH="$MVK_PATH"

echo ""
echo ">>> Building for iOS Device (arm64)..."
cmake --build . --config Release -- -sdk iphoneos CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

echo ""
echo ">>> Build complete!"
echo ">>> Output: $BUILD_DIR/Ps3Dream.app"
echo ""
echo "To install on device:"
echo "  1. Open Ps3Dream.xcodeproj in Xcode"
echo "  2. Set your Development Team in Signing & Capabilities"
echo "  3. Enable Developer Mode on your iOS device"
echo "  4. Build and Run"
echo ""
echo "IMPORTANT: Enable Developer Mode on your device for JIT:"
echo "  Settings > Privacy & Security > Developer Mode > On"
