import Foundation
@testable import AnimalDoku

/// Builds `[Cell]` boards from puzzle definitions for validator and integrity tests.
enum BoardBuilder {
    static func cells(for puzzle: Puzzle, animalPositions: Set<Position>) -> [Cell] {
        let lookup = regionIdLookup(for: puzzle)
        var cells: [Cell] = []
        cells.reserveCapacity(puzzle.size * puzzle.size)

        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                let position = Position(row: row, col: col)
                cells.append(
                    Cell(
                        row: row,
                        col: col,
                        regionId: lookup[position] ?? 0,
                        state: animalPositions.contains(position) ? .animal : .empty
                    )
                )
            }
        }

        return cells
    }

    static func cells(for puzzle: Puzzle, solution: [Position]) -> [Cell] {
        cells(for: puzzle, animalPositions: Set(solution))
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
}
