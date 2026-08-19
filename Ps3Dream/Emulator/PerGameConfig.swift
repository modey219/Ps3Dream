import Foundation

struct GameConfig {
    let titleId: String
    let writeColorBuffers: Bool
    let readColorBuffers: Bool
    let accurateZCULL: Bool
    let relaxedZCULLSync: Bool
    let spuBlockSize: String
    let sleepTimersAccuracy: String
    let asyncTextureStreaming: Bool
    let multithreadedRSX: Bool
    let accurateRSXReservation: Bool
    let strictRenderingMode: Bool
    let handleRSXMemoryTiling: Bool
    let disableVertexCache: Bool
    let msaa: String
    let frameLimit: String
    let shaderPrecision: String
    let spuXFloatAccuracy: String
    let spuDecoder: String
    let ppuDecoder: String
    let librariesControl: [String: String]

    var hasOptimizations: Bool {
        writeColorBuffers || readColorBuffers || accurateZCULL ||
        relaxedZCULLSync || multithreadedRSX || accurateRSXReservation ||
        strictRenderingMode || handleRSXMemoryTiling || disableVertexCache
    }

    static let defaults = GameConfig(
        titleId: "",
        writeColorBuffers: true,
        readColorBuffers: false,
        accurateZCULL: false,
        relaxedZCULLSync: true,
        spuBlockSize: "Safe",
        sleepTimersAccuracy: "As Host",
        asyncTextureStreaming: true,
        multithreadedRSX: true,
        accurateRSXReservation: false,
        strictRenderingMode: false,
        handleRSXMemoryTiling: false,
        disableVertexCache: false,
        msaa: "Disabled",
        frameLimit: "Off",
        shaderPrecision: "Auto",
        spuXFloatAccuracy: "Relaxed",
        spuDecoder: "Recompiler (LLVM)",
        ppuDecoder: "Recompiler (LLVM)",
        librariesControl: [:]
    )
}

class PerGameConfigManager {
    static let shared = PerGameConfigManager()
    private var database: [String: [String: String]] = [:]
    private var loaded = false

    private init() {}

    func load() {
        guard !loaded else { return }
        loaded = true

        guard let url = Bundle.main.url(forResource: "config_database", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[PerGameConfig] Could not load config_database.json")
            return
        }

        var count = 0
        for (titleId, value) in raw {
            guard let entry = value as? [String: String],
                  let configStr = entry["config"] else { continue }

            var settings: [String: String] = [:]
            var currentSection = ""

            for line in configStr.components(separatedBy: "\n") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasSuffix(":") {
                    currentSection = String(trimmed.dropLast())
                } else if !trimmed.isEmpty, let colonIdx = trimmed.firstIndex(of: ":") {
                    let key = String(trimmed[trimmed.startIndex..<colonIdx]).trimmingCharacters(in: .whitespaces)
                    let val = String(trimmed[trimmed.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                    settings["\(currentSection).\(key)"] = val
                }
            }

            if !settings.isEmpty {
                database[titleId] = settings
                count += 1
            }
        }

        print("[PerGameConfig] Loaded \(count) game configs")
    }

    func config(forTitleId titleId: String) -> GameConfig {
        load()
        guard let settings = database[titleId] else {
            return GameConfig.defaults
        }

        func get(_ key: String, default def: String = "") -> String {
            settings[key] ?? def
        }

        func getBool(_ key: String, default def: Bool = false) -> Bool {
            guard let val = settings[key] else { return def }
            return val.lowercased() == "true" || val.lowercased() == "enabled"
        }

        return GameConfig(
            titleId: titleId,
            writeColorBuffers: getBool("Video.Write Color Buffers", default: true),
            readColorBuffers: getBool("Video.Read Color Buffers"),
            accurateZCULL: getBool("Video.Accurate ZCULL stats"),
            relaxedZCULLSync: getBool("Video.Relaxed ZCULL Sync", default: true),
            spuBlockSize: get("Core.SPU Block Size", default: "Safe"),
            sleepTimersAccuracy: get("Core.Sleep Timers Accuracy", default: "As Host"),
            asyncTextureStreaming: getBool("Video.Asynchronous Texture Streaming", default: true),
            multithreadedRSX: getBool("Video.Multithreaded RSX", default: true),
            accurateRSXReservation: getBool("Core.Accurate RSX reservation access"),
            strictRenderingMode: getBool("Video.Strict Rendering Mode"),
            handleRSXMemoryTiling: getBool("Video.Handle RSX Memory Tiling"),
            disableVertexCache: getBool("Video.Disable Vertex Cache"),
            msaa: get("Video.MSAA", default: "Disabled"),
            frameLimit: get("Video.Frame limit", default: "Off"),
            shaderPrecision: get("Video.Shader Precision", default: "Auto"),
            spuXFloatAccuracy: get("Core.SPU XFloat Accuracy", default: "Relaxed"),
            spuDecoder: get("Core.SPU Decoder", default: "Recompiler (LLVM)"),
            ppuDecoder: get("Core.PPU Decoder", default: "Recompiler (LLVM)"),
            librariesControl: extractLibrariesControl(settings)
        )
    }

    func configAsYAML(forTitleId titleId: String) -> String {
        let config = config(forTitleId: titleId)
        var yaml = ""

        yaml += "Core:\n"
        yaml += "  SPU Block Size: \(config.spuBlockSize)\n"
        yaml += "  Sleep Timers Accuracy: \(config.sleepTimersAccuracy)\n"
        yaml += "  Accurate RSX reservation access: \(config.accurateRSXReservation)\n"
        yaml += "  SPU XFloat Accuracy: \(config.spuXFloatAccuracy)\n"
        yaml += "  SPU Decoder: \(config.spuDecoder)\n"
        yaml += "  PPU Decoder: \(config.ppuDecoder)\n"
        for (key, val) in config.librariesControl {
            yaml += "  \(key): \(val)\n"
        }

        yaml += "Video:\n"
        yaml += "  Write Color Buffers: \(config.writeColorBuffers)\n"
        yaml += "  Read Color Buffers: \(config.readColorBuffers)\n"
        yaml += "  Accurate ZCULL stats: \(config.accurateZCULL)\n"
        yaml += "  Relaxed ZCULL Sync: \(config.relaxedZCULLSync)\n"
        yaml += "  Asynchronous Texture Streaming: \(config.asyncTextureStreaming)\n"
        yaml += "  Multithreaded RSX: \(config.multithreadedRSX)\n"
        yaml += "  Strict Rendering Mode: \(config.strictRenderingMode)\n"
        yaml += "  Handle RSX Memory Tiling: \(config.handleRSXMemoryTiling)\n"
        yaml += "  Disable Vertex Cache: \(config.disableVertexCache)\n"
        yaml += "  MSAA: \(config.msaa)\n"
        yaml += "  Frame limit: \(config.frameLimit)\n"
        yaml += "  Shader Precision: \(config.shaderPrecision)\n"

        return yaml
    }

    private func extractLibrariesControl(_ settings: [String: String]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, val) in settings {
            if key.hasPrefix("Core.Libraries Control") {
                let libName = String(key.dropFirst("Core.Libraries Control.".count))
                result[libName] = val
            }
        }
        return result
    }

    var totalGames: Int {
        load()
        return database.count
    }
}
