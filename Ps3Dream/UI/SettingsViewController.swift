// Ps3Dream iOS - Settings View Controller
// Functional settings with persistence via UserDefaults

import UIKit

class SettingsViewController: UITableViewController {

    private let settings = AppSettings.shared

    private let sections = ["General", "Video", "Audio", "Input", "About"]
    private var items: [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        rebuildItems()
    }

    private func rebuildItems() {
        items = [
            ["Enable JIT", "Developer Mode Required"],
            ["Renderer", settings.renderer.name],
            ["Resolution Scale", settings.resolutionScale.name],
            ["Show FPS", settings.showFPS ? "ON" : "OFF"],
            ["Audio Backend", settings.audioBackend.name],
            ["Virtual Pad Opacity", "\(Int(settings.padOpacity * 100))%"],
            ["Ps3Dream v0.1", "Based on RPCS3 + APS3E"],
            ["Reset All Settings", ""]
        ]
    }

    // MARK: - Table

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        cell.accessoryView = nil
        cell.accessoryType = .none

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            // JIT toggle
            let toggle = UISwitch()
            toggle.isOn = ios_jit_enabled()
            toggle.addTarget(self, action: #selector(jitToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .default

        case (1, 0):
            // Renderer - cycle on tap
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (1, 1):
            // Resolution Scale - cycle on tap
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (1, 2):
            // Show FPS toggle
            let toggle = UISwitch()
            toggle.isOn = settings.showFPS
            toggle.addTarget(self, action: #selector(fpsToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .default

        case (2, 0):
            // Audio Backend
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (3, 0):
            // Pad opacity
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (4, 0):
            // About - show info
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (4, 1):
            // Reset settings
            cell.textLabel?.textColor = .systemRed
            cell.selectionStyle = .default

        default:
            cell.selectionStyle = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            break // Handled by toggle

        case (1, 0):
            cycleRenderer()

        case (1, 1):
            cycleResolution()

        case (1, 2):
            break // Handled by toggle

        case (2, 0):
            cycleAudio()

        case (3, 0):
            showOpacityPicker()

        case (4, 0):
            showAbout()

        case (4, 1):
            resetSettings()

        default:
            break
        }
    }

    // MARK: - Actions

    @objc private func jitToggled(_ sender: UISwitch) {
        if sender.isOn {
            let success = ios_enable_jit()
            if !success {
                let alert = UIAlertController(
                    title: "JIT Unavailable",
                    message: "Enable Developer Mode in Settings > Privacy & Security, then restart the app.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                sender.isOn = false
            }
            settings.jitEnabled = success
        }
    }

    @objc private func fpsToggled(_ sender: UISwitch) {
        settings.showFPS = sender.isOn
        rebuildItems()
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

    private func cycleRenderer() {
        let current = settings.renderer
        let next: AppSettings.Renderer = current == .vulkan ? .null : .vulkan
        settings.renderer = next
        rebuildItems()
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

    private func cycleResolution() {
        let scales: [AppSettings.ResolutionScale] = [.native, .r720p, .r480p, .r1080p]
        if let idx = scales.firstIndex(of: settings.resolutionScale) {
            settings.resolutionScale = scales[(idx + 1) % scales.count]
        }
        rebuildItems()
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

    private func cycleAudio() {
        let current = settings.audioBackend
        let next: AppSettings.AudioBackend = current == .cubeb ? .null : .cubeb
        settings.audioBackend = next
        rebuildItems()
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }

    private func showOpacityPicker() {
        let alert = UIAlertController(title: "Pad Opacity", message: nil, preferredStyle: .actionSheet)
        for val in [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0] {
            let title = "\(Int(val * 100))%"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.settings.padOpacity = Float(val)
                self?.rebuildItems()
                self?.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showAbout() {
        let alert = UIAlertController(title: "Ps3Dream", message: """
            PS3 Emulator for iOS
            Based on RPCS3 + APS3E Android
            Using MoltenVK for Vulkan -> Metal
            Requires iOS 17+ with Developer Mode

            RPCS3 Version: \(EmulatorManager.shared.rpcs3Version)
            GPU: \(EmulatorManager.shared.gpuInfo)
            CPU: \(EmulatorManager.shared.cpuInfo)
            """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func resetSettings() {
        let alert = UIAlertController(
            title: "Reset Settings",
            message: "Reset all settings to defaults?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.settings.reset()
            self?.rebuildItems()
            self?.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
