// Ps3Dream iOS - Emulator Manager
// Manages emulator lifecycle, state observation, and configuration

import Foundation

enum EmulatorState: Int {
    case unknown = 0
    case running = 1
    case stopped = 2
    case paused = 3
    case requestingPause = 4
    case requestingResume = 5
    case requestingStop = 6

    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .running: return "Running"
        case .stopped: return "Stopped"
        case .paused: return "Paused"
        case .requestingPause: return "Pausing..."
        case .requestingResume: return "Resuming..."
        case .requestingStop: return "Stopping..."
        }
    }

    var isRunning: Bool { self == .running }
    var isPaused: Bool { self == .paused }
    var isActive: Bool { self == .running || self == .paused }
}

protocol EmulatorManagerDelegate: AnyObject {
    func emulator(_ manager: EmulatorManager, didChangeState state: EmulatorState)
    func emulator(_ manager: EmulatorManager, didReceiveLog tag: String, message: String, level: Int)
}

class EmulatorManager {

    static let shared = EmulatorManager()

    weak var delegate: EmulatorManagerDelegate?

    private(set) var state: EmulatorState = .unknown
    private var stateObservation: Any?

    // Static handler storage. Swift closures that capture context cannot be
    // passed as C function pointers, so the C callbacks below bridge into
    // these static closures instead.
    static var statusHandler: ((Int32) -> Void)?
    static var logHandler: ((UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> Void)?

    private init() {
        setupCallbacks()
    }

    // MARK: - Callback Setup

    private func setupCallbacks() {
        EmulatorManager.statusHandler = { [weak self] status in
            guard let self = self else { return }
            let newState = EmulatorState(rawValue: Int(status)) ?? .unknown
            DispatchQueue.main.async {
                self.state = newState
                self.delegate?.emulator(self, didChangeState: newState)
            }
        }

        EmulatorManager.logHandler = { [weak self] tag, message, level in
            guard let self = self else { return }
            let tagStr = tag.map { String(cString: $0) } ?? ""
            let msgStr = message.map { String(cString: $0) } ?? ""
            DispatchQueue.main.async {
                self.delegate?.emulator(self, didReceiveLog: tagStr, message: msgStr, level: Int(level))
            }
        }

        ps3dream_set_status_callback(ps3dream_status_callback)
        ps3dream_set_log_callback(ps3dream_log_callback)
    }

    // MARK: - Emulation Control

    func bootGame(at path: String) {
        ps3dream_boot_game(path)
        ps3dream_boot()
    }

    func bootGame(fd: Int32) {
        ps3dream_boot_game_fd(fd)
        ps3dream_boot()
    }

    func bootGame(uri: String) {
        uri.withCString { ps3dream_boot_game_uri($0) }
        ps3dream_boot()
    }

    func pause() {
        guard state == .running else { return }
        ps3dream_pause()
    }

    func resume() {
        guard state == .paused else { return }
        ps3dream_resume()
    }

    func stop() {
        guard state != .stopped && state != .unknown else { return }
        ps3dream_quit()
    }

    func togglePause() {
        if state == .running {
            pause()
        } else if state == .paused {
            resume()
        }
    }

    // MARK: - Input

    func sendButton(_ button: String, pressed: Bool) {
        let keyCode = Self.buttonToKeyCode(button)
        ps3dream_key_event(Int32(keyCode), pressed, Int32(pressed ? 255 : 0))
    }

    func sendStick(_ stick: String, x: Float, y: Float) {
        let prefix = stick == "left" ? 100 : 104
        ps3dream_key_event(Int32(prefix + 0), x < -0.1, Int32(abs(x) * 255))
        ps3dream_key_event(Int32(prefix + 1), x > 0.1, Int32(abs(x) * 255))
        ps3dream_key_event(Int32(prefix + 2), y < -0.1, Int32(abs(y) * 255))
        ps3dream_key_event(Int32(prefix + 3), y > 0.1, Int32(abs(y) * 255))
    }

    // MARK: - Surface

    func setSurface(_ layer: UnsafeMutableRawPointer, width: Int, height: Int) {
        ps3dream_set_surface(layer, Int32(width), Int32(height))
    }

    func resize(width: Int, height: Int) {
        ps3dream_resize(Int32(width), Int32(height))
    }

    // MARK: - Firmware & Packages

    func installFirmware(at path: String) -> Bool {
        return path.withCString { ps3dream_install_firmware($0) }
    }

    func installPackage(at path: String) -> Bool {
        return path.withCString { ps3dream_install_pkg($0) }
    }

    // MARK: - Info

    var firmwareVersion: String {
        return String(cString: ps3dream_get_firmware_version())
    }

    var rpcs3Version: String {
        return String(cString: ps3dream_get_version())
    }

    var gpuInfo: String {
        return String(cString: ps3dream_get_gpu_info())
    }

    var cpuInfo: String {
        return String(cString: ps3dream_get_cpu_info())
    }

    // MARK: - Button Mapping

    static func buttonToKeyCode(_ button: String) -> Int {
        switch button {
        case "cross":     return 0
        case "circle":    return 1
        case "square":    return 2
        case "triangle":  return 3
        case "l1":        return 4
        case "r1":        return 5
        case "l2":        return 6
        case "r2":        return 7
        case "share":     return 8
        case "options":   return 9
        case "ps":        return 10
        case "l3":        return 11
        case "r3":        return 12
        case "dpad_up":   return 13
        case "dpad_down": return 14
        case "dpad_left": return 15
        case "dpad_right":return 16
        default: return 0
        }
    }
}

// Non-capturing shims that can be passed as C function pointers to the
// emulator bridge. They forward into the static handlers above.
func ps3dream_status_callback(_ status: Int32) {
    EmulatorManager.statusHandler?(status)
}

func ps3dream_log_callback(_ tag: UnsafePointer<CChar>?, _ message: UnsafePointer<CChar>?, _ level: Int32) {
    EmulatorManager.logHandler?(tag, message, level)
}
