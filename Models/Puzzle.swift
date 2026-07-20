import Foundation

/// Puzzle difficulty label (metadata only for MVP). See [Formal Rules §Puzzle](AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle).
enum Difficulty: String, Codable, Equatable, CaseIterable, Hashable {
    case easy
    case medium
    case hard
    case expert

    var displayName: String {
        switch self {
        case .easy:
            String(localized: "difficulty.easy", defaultValue: "Easy")
        case .medium:
            String(localized: "difficulty.medium", defaultValue: "Medium")
        case .hard:
            String(localized: "difficulty.hard", defaultValue: "Hard")
        case .expert:
            String(localized: "difficulty.expert", defaultValue: "Expert")
        }
    }
}

/// Bundled puzzle definition. See [Formal Rules §Puzzle](AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle).
struct Puzzle: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let size: Int
    let regions: [Region]
    let solution: [Position]
    let difficulty: Difficulty
    /// Pre-filled givens; always `[]` for MVP puzzles.
    let initialPlacements: [Position]
}
