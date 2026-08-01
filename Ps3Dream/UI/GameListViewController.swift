// Ps3Dream iOS - Game List View Controller
// Main screen showing installed PS3 games (replaces Android MainActivity)

import UIKit
import UniformTypeIdentifiers

struct PS3Game {
    let titleId: String
    let name: String
    let iconPath: String?
    let gamePath: String
}

class GameListViewController: UITableViewController, UIDocumentPickerDelegate {

    private var games: [PS3Game] = []
    private let cellId = "GameCell"
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let romsPath = "PS3_Games"
    private let firmwarePath = "Firmware"
    private var activePickerType = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ps3Dream"
        view.backgroundColor = UIColor.systemBackground

        tableView.register(GameCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 80

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain, target: self, action: #selector(openSettings))

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGame)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain,
                            target: self, action: #selector(refreshGames))
        ]

        setupDirectories()
        refreshGames()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshGames()
    }

    // MARK: - Setup

    private func setupDirectories() {
        let paths = [romsPath, firmwarePath]
        for p in paths {
            let dir = documentsPath.appendingPathComponent(p)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    // MARK: - Game Scanning

    @objc private func refreshGames() {
        games.removeAll()
        let basePath = documentsPath.appendingPathComponent(romsPath)

        guard let items = try? FileManager.default.contentsOfDirectory(
            at: basePath, includingPropertiesForKeys: [.isDirectoryKey]) else { return }

        for item in items {
            let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if isDir {
                let ebootPath = item.appendingPathComponent("PS3_GAME")
                    .appendingPathComponent("USRDIR")
                    .appendingPathComponent("EBOOT.BIN")
                if FileManager.default.fileExists(atPath: ebootPath.path) {
                    let titleId = item.lastPathComponent
                    let sfoPath = item.appendingPathComponent("PS3_GAME")
                        .appendingPathComponent("PARAM.SFO")
                    let name = readSFOTitle(sfoPath: sfoPath.path) ?? titleId
                    games.append(PS3Game(titleId: titleId, name: name, iconPath: nil, gamePath: item.path))
                }
            } else if item.pathExtension.lowercased() == "iso" ||
                        item.pathExtension.lowercased() == "bin" {
                let name = item.deletingPathExtension().lastPathComponent
                games.append(PS3Game(titleId: name, name: name, iconPath: nil, gamePath: item.path))
            }
        }

        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if games.isEmpty {
            let label = UILabel()
            label.text = "No games found\n\nTap + to add PS3 games\nor connect to iTunes File Sharing"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: - SFO Parser

    private func readSFOTitle(sfoPath: String) -> String? {
        guard let data = FileManager.default.contents(atPath: sfoPath) else { return nil }
        let dataBytes = [UInt8](data)
        guard dataBytes.count > 16 else { return nil }

        let keyCount = Int(dataBytes[4])
        let keyOffset = Int(UInt32(dataBytes[8]) | (UInt32(dataBytes[9]) << 8) |
                            (UInt32(dataBytes[10]) << 16) | (UInt32(dataBytes[11]) << 24))
        let dataOffset = Int(UInt32(dataBytes[12]) | (UInt32(dataBytes[13]) << 8) |
                            (UInt32(dataBytes[14]) << 16) | (UInt32(dataBytes[15]) << 24))

        let keyTableEnd = keyOffset + min(0x400, dataBytes.count - keyOffset)
        guard keyOffset >= 0, keyOffset < keyTableEnd, keyTableEnd <= dataBytes.count else { return nil }

        if let keyTable = String(data: data.subdata(in: keyOffset..<keyTableEnd), encoding: .utf8),
           let range = keyTable.range(of: "TITLE") {
            let index = keyTable.distance(from: keyTable.startIndex, to: range.lowerBound)
            let actualKeyOffset = keyOffset + index
            let keyIndex = (actualKeyOffset - keyOffset) / 16
            let idxEntry = dataOffset + keyIndex * 16
            if idxEntry + 8 <= dataBytes.count {
                let valOffset = Int(UInt32(dataBytes[idxEntry]) | (UInt32(dataBytes[idxEntry+1]) << 8) |
                                   (UInt32(dataBytes[idxEntry+2]) << 16) | (UInt32(dataBytes[idxEntry+3]) << 24))
                let dataSize = Int(UInt16(dataBytes[idxEntry+4]) | (UInt16(dataBytes[idxEntry+5]) << 8))
                let dataStart = dataOffset + keyCount * 16 + valOffset
                if dataStart + dataSize <= dataBytes.count,
                   let str = String(bytes: dataBytes[dataStart..<(dataStart+dataSize)], encoding: .utf8) {
                    return str.trimmingCharacters(in: .controlCharacters)
                }
            }
        }
        return nil
    }

    // MARK: - Actions

    @objc private func addGame() {
        let alert = UIAlertController(title: "Add Game", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Import PKG File", style: .default) { [weak self] _ in
            self?.importPKG()
        })

        alert.addAction(UIAlertAction(title: "Import Game Folder", style: .default) { [weak self] _ in
            self?.importGameFolder()
        })

        alert.addAction(UIAlertAction(title: "Install Firmware (PUP)", style: .default) { [weak self] _ in
            self?.importFirmware()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - Firmware Install

    private func importFirmware() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        activePickerType = 2 // Firmware picker
        present(picker, animated: true)
    }

    private func installFirmware(at url: URL) {
        let alert = UIAlertController(
            title: "Install Firmware",
            message: "Installing PS3 firmware may take several minutes. Do not close the app.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Install", style: .default) { [weak self] _ in
            self?.performFirmwareInstall(at: url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performFirmwareInstall(at url: URL) {
        let loadingAlert = UIAlertController(
            title: "Installing Firmware",
            message: "Please wait...",
            preferredStyle: .alert)
        present(loadingAlert, animated: true)

        DispatchQueue.global(qos: .userInitiated).async {
            let success = EmulatorManager.shared.installFirmware(at: url.path)

            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true) {
                    let resultAlert = UIAlertController(
                        title: success ? "Success" : "Failed",
                        message: success ? "PS3 firmware installed successfully." : "Failed to install firmware. The PUP file may be corrupted.",
                        preferredStyle: .alert)
                        resultAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(resultAlert, animated: true)
                }
            }
        }
    }

    // MARK: - Game Import

    private func importPKG() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        activePickerType = 1 // PKG picker
        present(picker, animated: true)
    }

    private func importGameFolder() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        activePickerType = 0 // Folder picker
        present(picker, animated: true)
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let pickerType = activePickerType
        activePickerType = -1

        switch pickerType {
        case 0:
            // Game folder
            let dest = documentsPath.appendingPathComponent(romsPath)
                .appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.copyItem(at: url, to: dest)
            refreshGames()

        case 1:
            // PKG file - install it
            let loadingAlert = UIAlertController(
                title: "Installing Package",
                message: "Please wait...",
                preferredStyle: .alert)
            present(loadingAlert, animated: true)

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let success = EmulatorManager.shared.installPackage(at: url.path)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true) {
                        let resultAlert = UIAlertController(
                            title: success ? "Installed" : "Failed",
                            message: success ? "Package installed successfully." : "Failed to install package.",
                            preferredStyle: .alert)
                        resultAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(resultAlert, animated: true)
                        if success { self?.refreshGames() }
                    }
                }
            }

        case 2:
            // Firmware PUP
            installFirmware(at: url)

        default:
            break
        }
    }

    // MARK: - Settings

    @objc private func openSettings() {
        let settings = SettingsViewController()
        navigationController?.pushViewController(settings, animated: true)
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GameCell
        let game = games[indexPath.row]
        cell.configure(title: game.name, subtitle: game.titleId)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = games[indexPath.row]

        let alert = UIAlertController(title: game.name, message: "Start game?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play", style: .default) { [weak self] _ in
            self?.launchGame(game)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, handler in
            guard let self = self else { return }
            let game = self.games[indexPath.row]
            try? FileManager.default.removeItem(atPath: game.gamePath)
            self.games.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState()
            handler(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func launchGame(_ game: PS3Game) {
        let emulator = EmulatorViewController(game: game)
        emulator.modalPresentationStyle = .fullScreen
        present(emulator, animated: true)
    }
}
