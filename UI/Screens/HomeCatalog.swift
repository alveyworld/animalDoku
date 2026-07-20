import Foundation

/// Filters bundled puzzles for the home screen.
enum HomeCatalog {
    /// Playable catalog size for v1.x (excludes UI-test fixtures like 4×4).
    static let playableBoardSize = 8

    /// Bundled puzzles intended for Home (standard board size only).
    static func playable(_ puzzles: [Puzzle]) -> [Puzzle] {
        puzzles.filter { $0.size == playableBoardSize }
    }

    /// Returns puzzles matching `difficulty`, or all puzzles when `difficulty` is `nil`.
    /// Preserves input order (authored / bundle order).
    static func filtered(_ puzzles: [Puzzle], difficulty: Difficulty?) -> [Puzzle] {
        guard let difficulty else { return puzzles }
        return puzzles.filter { $0.difficulty == difficulty }
    }
}
