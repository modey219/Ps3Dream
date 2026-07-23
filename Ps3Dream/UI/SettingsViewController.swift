// Ps3Dream iOS - Settings View Controller

import UIKit

class SettingsViewController: UITableViewController {

    private let sections = ["General", "Video", "Audio", "Input", "About"]
    private let items = [
        ["Enable JIT", "Developer Mode Required"],
        ["Renderer", "Vulkan (MoltenVK)"],
        ["Resolution Scale", "720p"],
        ["Audio Backend", "Cubeb"],
        ["Virtual Pad Opacity", "60%"],
        ["Ps3Dream v0.1", "Based on RPCS3 + APS3E"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    override func tableView(_ t: UITableView, numberOfRowsInSection section: Int) -> Int { items[section].count }
    override func tableView(_ t: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section] }

    override func tableView(_ t: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.selectionStyle = .none

        if indexPath.section == 0 && indexPath.row == 0 {
            let toggle = UISwitch()
            toggle.isOn = ios_jit_enabled()
            toggle.addTarget(self, action: #selector(jitToggled(_:)), for: .valueChanged)
            cell.accessoryView = toggle
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

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
        }
    }

    override func tableView(_ t: UITableView, didSelectRowAt indexPath: IndexPath) {
        t.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 4 {
            let alert = UIAlertController(title: "Ps3Dream", message: """
                PS3 Emulator for iOS
                Based on RPCS3 + APS3E Android
                Using MoltenVK for Vulkan -> Metal
                Requires iOS 17+ with Developer Mode
                """, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
