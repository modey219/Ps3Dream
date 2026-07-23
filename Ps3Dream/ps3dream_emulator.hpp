// Ps3Dream iOS - Emulator Header
// Umbrella include for the bridge layer

#pragma once

// RPCS3 System headers needed by the bridge
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
#pragma clang diagnostic ignored "-Wold-style-cast"
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#pragma clang diagnostic ignored "-Wsign-compare"

#include "Emu/System.h"
#include "Emu/system_config.h"
#include "Emu/system_utils.hpp"
#include "Emu/IdManager.h"
#include "Emu/VFS.h"
#include "Emu/vfs_config.h"
#include "Emu/system_progress.hpp"

#include "Emu/Cell/PPUThread.h"
#include "Emu/Cell/SPUThread.h"
#include "Emu/CPU/CPUThread.h"

#include "Emu/Io/PadHandler.h"
#include "Emu/Io/Null/NullPadHandler.h"
#include "Emu/Io/Null/NullKeyboardHandler.h"
#include "Emu/Io/Null/NullMouseHandler.h"
#include "Emu/Io/Null/null_music_handler.h"
#include "Emu/Io/Null/null_camera_handler.h"

#include "Emu/Audio/Null/NullAudioBackend.h"
#include "Emu/Audio/Cubeb/CubebBackend.h"

#include "Emu/RSX/VK/VKGSRender.h"
#include "Emu/RSX/GSFrameBase.h"
#include "Emu/RSX/Overlays/overlay_save_dialog.h"
#include "Emu/RSX/Overlays/overlay_trophy_notification.h"

#include "Input/pad_thread.h"
#include "Input/product_info.h"

#include "Emu/Cell/Modules/cellSaveData.h"
#include "Emu/Cell/Modules/sceNpTrophy.h"
#include "Emu/Cell/Modules/cellSysutil.h"
#include "Emu/Cell/Modules/cellMusic.h"

#include "Crypto/unpkg.h"
#include "Crypto/unself.h"

#include "Loader/PUP.h"
#include "Loader/TAR.h"
#include "Loader/PSF.h"
#include "Loader/iso.h"

#include "Utilities/File.h"
#include "Utilities/Thread.h"
#include "util/sysinfo.hpp"
#include "util/serialization_ext.hpp"
#include "util/logs.hpp"
#include "util/video_provider.h"

#include "rpcs3_version.h"

#include "yaml-cpp/yaml.h"

#pragma clang diagnostic pop
