import Foundation

/// Serializable snapshot of an in-progress or completed game (v1.1 persistence).
/// See [Formal Rules §SaveGame](AnimalDoku_Formal_Rules_and_Data_Model.md#savegame-v11).
struct SaveGame: Codable, Equatable {
    let puzzleId: String
    let elapsedSeconds: Int
    let cells: [Cell]
    let hintsUsed: Int
    /// Not tracked in MVP; always `0` until v1.1 mistake counting ships.
    let mistakes: Int
    let completed: Bool
}
