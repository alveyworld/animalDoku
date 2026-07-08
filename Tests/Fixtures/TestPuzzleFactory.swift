import Foundation
import XCTest
@testable import AnimalDoku

/// Deterministic puzzle fixtures for engine tests (P3.7).
/// Prefer these over production `puzzle-001` to keep cases minimal.
enum TestPuzzleFactory {
    /// 4×4 puzzle with a valid solution. Matches bundled `puzzle-valid-4x4.json`.
    static func miniPuzzle() -> Puzzle {
        Puzzle(
            id: "test-mini-4x4",
            size: 4,
            regions: [
                Region(id: 0, color: "#A8D8EA", cells: [
                    Position(row: 0, col: 0), Position(row: 0, col: 1),
                    Position(row: 1, col: 0), Position(row: 1, col: 1),
                ]),
                Region(id: 1, color: "#B8E0D2", cells: [
                    Position(row: 0, col: 2), Position(row: 0, col: 3),
                    Position(row: 1, col: 2), Position(row: 1, col: 3),
                ]),
                Region(id: 2, color: "#D4A5C9", cells: [
                    Position(row: 2, col: 0), Position(row: 2, col: 1),
                    Position(row: 3, col: 0), Position(row: 3, col: 1),
                ]),
                Region(id: 3, color: "#FFD4A3", cells: [
                    Position(row: 2, col: 2), Position(row: 2, col: 3),
                    Position(row: 3, col: 2), Position(row: 3, col: 3),
                ]),
            ],
            solution: [
                Position(row: 0, col: 1),
                Position(row: 1, col: 3),
                Position(row: 2, col: 0),
                Position(row: 3, col: 2),
            ],
            difficulty: .easy,
            initialPlacements: []
        )
    }

    /// 8×8 grid for init/region tests; no solution placements.
    static func emptyGrid8x8() -> Puzzle {
        Puzzle(
            id: "test-8x8",
            size: 8,
            regions: (0..<8).map { row in
                Region(
                    id: row,
                    color: "#A8D8EA",
                    cells: (0..<8).map { col in Position(row: row, col: col) }
                )
            },
            solution: [],
            difficulty: .easy,
            initialPlacements: []
        )
    }

    static func loadBundledMini() throws -> Puzzle {
        try PuzzleLoader().load(named: "puzzle-valid-4x4")
    }
}

enum GameSessionTestHelpers {
    static func assertCellState(
        _ session: GameSession,
        at position: Position,
        equals expected: CellState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(session.cell(at: position).state, expected, file: file, line: line)
    }

    static func assertBoardMatchesSolution(
        _ session: GameSession,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for position in session.puzzle.solution {
            assertCellState(session, at: position, equals: .animal, file: file, line: line)
        }
    }

    static func solveViaPlacements(_ session: GameSession) {
        session.inputMode = .place
        for position in session.puzzle.solution {
            session.tap(at: position)
        }
    }
}
