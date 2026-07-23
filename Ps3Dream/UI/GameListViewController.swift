// Ps3Dream iOS - Game List View Controller
// Main screen showing installed PS3 games (replaces Android MainActivity)

import UIKit

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

        setupGameDirectory()
        refreshGames()
    }

    private func setupGameDirectory() {
        let path = documentsPath.appendingPathComponent(romsPath)
        try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    }

    @objc private func refreshGames() {
        games.removeAll()
        let basePath = documentsPath.appendingPathComponent(romsPath)

        guard let items = try? FileManager.default.contentsOfDirectory(
            at: basePath, includingPropertiesForKeys: [.isDirectoryKey]) else { return }

        for item in items {
            let isDir = (try? item.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if isDir {
                let ebootPath = item.appendingPathComponent("PS3_GAME").appendingPathComponent("USRDIR").appendingPathComponent("EBOOT.BIN")
                if FileManager.default.fileExists(atPath: ebootPath.path) {
                    let titleId = item.lastPathComponent
                    let sfoPath = item.appendingPathComponent("PS3_GAME").appendingPathComponent("PARAM.SFO")
                    let name = readSFOTitle(sfoPath: sfoPath.path) ?? titleId
                    games.append(PS3Game(titleId: titleId, name: name, iconPath: nil, gamePath: item.path))
                }
            } else if item.pathExtension.lowercased() == "iso" || item.pathExtension.lowercased() == "bin" {
                let name = item.deletingPathExtension().lastPathComponent
                games.append(PS3Game(titleId: name, name: name, iconPath: nil, gamePath: item.path))
            }
        }

        tableView.reloadData()
    }

    private func readSFOTitle(sfoPath: String) -> String? {
        guard let data = FileManager.default.contents(atPath: sfoPath) else { return nil }
        // Basic SFO parser - find "TITLE" key
        let dataBytes = [UInt8](data)
        guard dataBytes.count > 8 else { return nil }

        let keyCount = Int(dataBytes[4])
        let keyOffset = Int(UInt32(dataBytes[8]) | (UInt32(dataBytes[9]) << 8) |
                            (UInt32(dataBytes[10]) << 16) | (UInt32(dataBytes[11]) << 24))
        let dataOffset = Int(UInt32(dataBytes[12]) | (UInt32(dataBytes[13]) << 8) |
                            (UInt32(dataBytes[14]) << 16) | (UInt32(dataBytes[15]) << 24))

        // Search for "TITLE" in key table
        if let keyTable = String(data: data, range: keyOffset..<(keyOffset + 0x400)),
           let range = keyTable.range(of: "TITLE") {
            let index = keyTable.distance(from: keyTable.startIndex, to: range.lowerBound)
            let actualKeyOffset = keyOffset + index

            // Read index table entry (16 bytes each)
            let keyIndex = (actualKeyOffset - keyOffset) / 16 // approximate
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

    @objc private func addGame() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let dest = documentsPath.appendingPathComponent(romsPath).appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.copyItem(at: url, to: dest)
        refreshGames()
    }

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
        alert.addAction(UIAlertAction(title: "Play", style: .default) { _ in
            self.launchGame(game)
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
