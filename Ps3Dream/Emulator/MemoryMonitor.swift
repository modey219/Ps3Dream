import Foundation
import UIKit

class MemoryMonitor {
    static let shared = MemoryMonitor()
    static let memoryPressureNotification = Notification.Name("MemoryPressureWarning")

    private var timer: Timer?
    private var warningLevel: MemoryWarningLevel = .normal

    enum MemoryWarningLevel: Int {
        case normal = 0
        case warning = 1
        case critical = 2

        var description: String {
            switch self {
            case .normal: return "Normal"
            case .warning: return "Warning"
            case .critical: return "Critical"
            }
        }
    }

    struct MemoryInfo {
        let totalRAM: UInt64
        let usedRAM: UInt64
        let availableRAM: UInt64
        let appUsedRAM: UInt64
        let pressureLevel: MemoryWarningLevel

        var totalRAMMB: Int { Int(totalRAM / 1024 / 1024) }
        var usedRAMMB: Int { Int(usedRAM / 1024 / 1024) }
        var availableRAMMB: Int { Int(availableRAM / 1024 / 1024) }
        var appUsedRAMMB: Int { Int(appUsedRAM / 1024 / 1024) }

        var recommendsLowMode: Bool {
            totalRAMMB <= 4096 || availableRAMMB < 1024
        }
    }

    private init() {}

    func startMonitoring(interval: TimeInterval = 2.0) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkMemory()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func getCurrentInfo() -> MemoryInfo {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        let appUsed = result == KERN_SUCCESS ? UInt64(info.resident_size) : 0

        let totalRAM = ProcessInfo.processInfo.physicalMemory

        var pagesFree: UInt64 = 0
        let pageSize: UInt64 = UInt64(vm_page_size)
        var HostVmInfo64 = vm_statistics64()
        var hostSize = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        _ = withUnsafeMutablePointer(to: &HostVmInfo64) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(hostSize)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &hostSize)
            }
        }

        pagesFree = UInt64(HostVmInfo64.free_count)

        let availableRAM = pagesFree * pageSize

        let level: MemoryWarningLevel
        if Double(availableRAM) / Double(totalRAM) < 0.1 {
            level = .critical
        } else if Double(availableRAM) / Double(totalRAM) < 0.2 {
            level = .warning
        } else {
            level = .normal
        }

        if level != warningLevel {
            warningLevel = level
            if level != .normal {
                NotificationCenter.default.post(
                    name: Self.memoryPressureNotification, object: level)
            }
        }

        return MemoryInfo(
            totalRAM: totalRAM,
            usedRAM: totalRAM - availableRAM,
            availableRAM: availableRAM,
            appUsedRAM: appUsed,
            pressureLevel: level
        )
    }

    private func checkMemory() {
        _ = getCurrentInfo()
    }

    static var deviceMemoryMB: Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1024 / 1024)
    }

    static var isLowEndDevice: Bool {
        deviceMemoryMB <= 4096
    }

    static var recommendedSPUThreads: Int {
        let totalMB = deviceMemoryMB
        if totalMB <= 3072 { return 1 }
        if totalMB <= 4096 { return 2 }
        return 4
    }
}
