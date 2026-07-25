// Ps3Dream iOS - App Settings
// Persistent configuration using UserDefaults

import Foundation

class AppSettings {

    static let shared = AppSettings()
    static let didChangeNotification = Notification.Name("AppSettingsDidChange")

    private let defaults = UserDefaults.standard

    // Keys
    private enum Keys {
        static let renderer = "renderer"
        static let resolutionScale = "resolutionScale"
        static let audioBackend = "audioBackend"
        static let padOpacity = "padOpacity"
        static let enableVSync = "enableVSync"
        static let showFPS = "showFPS"
        static let jitEnabled = "jitEnabled"
        static let lastFirmwareVersion = "lastFirmwareVersion"
        static let gameDirectories = "gameDirectories"
    }

    enum Renderer: Int {
        case vulkan = 0
        case null = 1

        var name: String {
            switch self {
            case .vulkan: return "Vulkan (MoltenVK)"
            case .null: return "Null (No Rendering)"
            }
        }
    }

    enum ResolutionScale: Int {
        case native = 0
        case r720p = 1
        case r480p = 2
        case r1080p = 3

        var scale: Float {
            switch self {
            case .native: return 1.0
            case .r720p: return 0.75
            case .r480p: return 0.5
            case .r1080p: return 1.5
            }
        }

        var name: String {
            switch self {
            case .native: return "Native"
            case .r720p: return "720p"
            case .r480p: return "480p"
            case .r1080p: return "1080p"
            }
        }
    }

    enum AudioBackend: Int {
        case cubeb = 0
        case null = 1

        var name: String {
            switch self {
            case .cubeb: return "Cubeb"
            case .null: return "Null (No Audio)"
            }
        }
    }

    // MARK: - Properties

    var renderer: Renderer {
        get { Renderer(rawValue: defaults.integer(forKey: Keys.renderer)) ?? .vulkan }
        set { set(.vulkan, forKey: Keys.renderer) }
    }

    var resolutionScale: ResolutionScale {
        get { ResolutionScale(rawValue: defaults.integer(forKey: Keys.resolutionScale)) ?? .r720p }
        set { set(newValue.rawValue, forKey: Keys.resolutionScale) }
    }

    var audioBackend: AudioBackend {
        get { AudioBackend(rawValue: defaults.integer(forKey: Keys.audioBackend)) ?? .cubeb }
        set { set(newValue.rawValue, forKey: Keys.audioBackend) }
    }

    var padOpacity: Float {
        get {
            let val = defaults.float(forKey: Keys.padOpacity)
            return val == 0 ? 0.6 : val
        }
        set { set(newValue, forKey: Keys.padOpacity) }
    }

    var enableVSync: Bool {
        get { defaults.object(forKey: Keys.enableVSync) as? Bool ?? true }
        set { set(newValue, forKey: Keys.enableVSync) }
    }

    var showFPS: Bool {
        get { defaults.object(forKey: Keys.showFPS) as? Bool ?? false }
        set { set(newValue, forKey: Keys.showFPS) }
    }

    var jitEnabled: Bool {
        get { defaults.object(forKey: Keys.jitEnabled) as? Bool ?? false }
        set { set(newValue, forKey: Keys.jitEnabled) }
    }

    var lastFirmwareVersion: String? {
        get { defaults.string(forKey: Keys.lastFirmwareVersion) }
        set { set(newValue, forKey: Keys.lastFirmwareVersion) }
    }

    var gameDirectories: [String] {
        get { defaults.stringArray(forKey: Keys.gameDirectories) ?? [] }
        set { set(newValue, forKey: Keys.gameDirectories) }
    }

    // MARK: - Helpers

    private func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }

    func reset() {
        let domain = Bundle.main.bundleIdentifier ?? "Ps3Dream"
        defaults.removePersistentDomain(forName: domain)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
