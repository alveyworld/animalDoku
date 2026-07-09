import Foundation
@testable import AnimalDoku

/// Test-only backtracking solver for puzzle uniqueness checks (P6.1).
enum PuzzleSolver {
    private static let neighborOffsets: [(dr: Int, dc: Int)] = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1),           (0, 1),
        (1, -1),  (1, 0),  (1, 1),
    ]

    /// Enumerates valid solutions (one animal per row, obeying Rules 1–4).
    /// Stops once `limit` solutions are found.
    static func solutions(
        for puzzle: Puzzle,
        limit: Int = 2,
        validator: Validator = Validator()
    ) -> [[Position]] {
        guard limit > 0 else { return [] }

        let size = puzzle.size
        let regionLookup = regionIdLookup(for: puzzle)
        var found: [[Position]] = []
        var current: [Position] = []
        current.reserveCapacity(size)

        func canPlace(_ position: Position) -> Bool {
            guard let regionId = regionLookup[position] else { return false }

            for placed in current {
                if placed.col == position.col { return false }
                if regionLookup[placed] == regionId { return false }
                if touches(placed, position) { return false }
            }
            return true
        }

        func search(row: Int) {
            guard found.count < limit else { return }
            guard row < size else {
                let cells = BoardBuilder.cells(for: puzzle, solution: current)
                let result = validator.validate(cells: cells, puzzle: puzzle)
                if result.isComplete {
                    found.append(current)
                }
                return
            }

            for col in 0..<size {
                let position = Position(row: row, col: col)
                guard canPlace(position) else { continue }
                current.append(position)
                search(row: row + 1)
                current.removeLast()
                if found.count >= limit { return }
            }
        }

        search(row: 0)
        return found
    }

    private static func regionIdLookup(for puzzle: Puzzle) -> [Position: Int] {
        var lookup: [Position: Int] = [:]
        for region in puzzle.regions {
            for position in region.cells {
                lookup[position] = region.id
            }
        }
        return lookup
    }

    private static func touches(_ lhs: Position, _ rhs: Position) -> Bool {
        let rowDelta = abs(lhs.row - rhs.row)
        let colDelta = abs(lhs.col - rhs.col)
        return rowDelta <= 1 && colDelta <= 1 && (rowDelta != 0 || colDelta != 0)
    }
}
