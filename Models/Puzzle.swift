import Foundation

/// Puzzle difficulty label (metadata only for MVP). See [Formal Rules §Puzzle](AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle).
enum Difficulty: String, Codable, Equatable {
    case easy
    case medium
    case hard
    case expert
}

/// Bundled puzzle definition. See [Formal Rules §Puzzle](AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle).
struct Puzzle: Codable, Identifiable, Equatable {
    let id: String
    let size: Int
    let regions: [Region]
    let solution: [Position]
    let difficulty: Difficulty
    /// Pre-filled givens; always `[]` for MVP puzzles.
    let initialPlacements: [Position]
}
