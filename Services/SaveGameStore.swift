import Foundation
import Observation

protocol SaveGamePersisting: AnyObject {
    func save(_ game: SaveGame)
    func load(puzzleId: String) -> SaveGame?
    func clear(puzzleId: String)
}

/// Persists `SaveGame` snapshots to disk (one file per `puzzleId`).
///
/// Writes are atomic (temp file + replace). Corrupt or unknown-schema payloads are discarded.
@Observable
final class SaveGameStore: SaveGamePersisting {
    private let directory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        directory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.sortedKeys]
        self.decoder = JSONDecoder()

        if let directory {
            self.directory = directory
        } else {
            let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.directory = base
                .appendingPathComponent("AnimalDoku", isDirectory: true)
                .appendingPathComponent("Saves", isDirectory: true)
        }

        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func save(_ game: SaveGame) {
        let url = fileURL(for: game.puzzleId)
        do {
            let data = try encoder.encode(game)
            let tempURL = url.appendingPathExtension("tmp")
            try data.write(to: tempURL, options: .atomic)
            if fileManager.fileExists(atPath: url.path) {
                _ = try fileManager.replaceItemAt(url, withItemAt: tempURL)
            } else {
                try fileManager.moveItem(at: tempURL, to: url)
            }
        } catch {
            try? fileManager.removeItem(at: url.appendingPathExtension("tmp"))
            // Fail silently — never crash on persistence.
        }
    }

    func load(puzzleId: String) -> SaveGame? {
        let url = fileURL(for: puzzleId)
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let game = try decoder.decode(SaveGame.self, from: data)
            guard game.schemaVersion == SaveGame.currentSchemaVersion else {
                clear(puzzleId: puzzleId)
                return nil
            }
            guard game.puzzleId == puzzleId else {
                clear(puzzleId: puzzleId)
                return nil
            }
            return game
        } catch {
            clear(puzzleId: puzzleId)
            return nil
        }
    }

    func clear(puzzleId: String) {
        let url = fileURL(for: puzzleId)
        try? fileManager.removeItem(at: url)
        try? fileManager.removeItem(at: url.appendingPathExtension("tmp"))
    }

    /// Removes every save file (UI-test fresh launch).
    func clearAll() {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else { return }
        for url in urls {
            try? fileManager.removeItem(at: url)
        }
    }

    private func fileURL(for puzzleId: String) -> URL {
        let safeName = puzzleId
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return directory.appendingPathComponent("\(safeName).json")
    }
}

/// In-memory store for unit tests and previews.
final class InMemorySaveGameStore: SaveGamePersisting {
    private(set) var storage: [String: SaveGame] = [:]

    func save(_ game: SaveGame) {
        storage[game.puzzleId] = game
    }

    func load(puzzleId: String) -> SaveGame? {
        storage[puzzleId]
    }

    func clear(puzzleId: String) {
        storage.removeValue(forKey: puzzleId)
    }
}
