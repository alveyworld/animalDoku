import Foundation

/// Serializable snapshot of an in-progress or completed game (v1.1 persistence).
/// See [Formal Rules §SaveGame](AnimalDoku_Formal_Rules_and_Data_Model.md#savegame-v11).
struct SaveGame: Codable, Equatable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let puzzleId: String
    let elapsedSeconds: Int
    let cells: [Cell]
    let hintsUsed: Int
    /// Not tracked in MVP; always `0` until mistake counting ships.
    let mistakes: Int
    let completed: Bool

    init(
        schemaVersion: Int = SaveGame.currentSchemaVersion,
        puzzleId: String,
        elapsedSeconds: Int,
        cells: [Cell],
        hintsUsed: Int,
        mistakes: Int = 0,
        completed: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.puzzleId = puzzleId
        self.elapsedSeconds = elapsedSeconds
        self.cells = cells
        self.hintsUsed = hintsUsed
        self.mistakes = mistakes
        self.completed = completed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion)
            ?? SaveGame.currentSchemaVersion
        puzzleId = try container.decode(String.self, forKey: .puzzleId)
        elapsedSeconds = try container.decode(Int.self, forKey: .elapsedSeconds)
        cells = try container.decode([Cell].self, forKey: .cells)
        hintsUsed = try container.decode(Int.self, forKey: .hintsUsed)
        mistakes = try container.decodeIfPresent(Int.self, forKey: .mistakes) ?? 0
        completed = try container.decode(Bool.self, forKey: .completed)
    }
}

enum SaveGameRestoreError: Error, Equatable {
    case puzzleIdMismatch
    case invalidCellCount
    case invalidCellLayout
}
