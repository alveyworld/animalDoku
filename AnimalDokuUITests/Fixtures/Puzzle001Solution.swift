import Foundation

/// Mirror of `Resources/Puzzles/puzzle-001.json` solution for UI tests (P6.2).
/// Keep in sync with the bundled JSON — guarded by `Puzzle001SolutionContractTests`.
enum Puzzle001 {
    static let puzzleName = "puzzle-001"

    /// Solution placements (row, col), matching `puzzle-001.json`.
    static let solution: [(row: Int, col: Int)] = [
        (0, 3),
        (1, 6),
        (2, 1),
        (3, 5),
        (4, 2),
        (5, 0),
        (6, 4),
        (7, 7),
    ]

    static func cellId(row: Int, col: Int) -> String {
        "cell_\(row)_\(col)"
    }
}
