import XCTest
@testable import AnimalDoku

/// Guards UI-test solution fixture drift from bundled `puzzle-001.json` (P6.2).
final class Puzzle001SolutionContractTests: XCTestCase {
    /// Must match `AnimalDokuUITests/Fixtures/Puzzle001Solution.swift`.
    private static let uiTestFixtureSolution: [Position] = [
        Position(row: 0, col: 3),
        Position(row: 1, col: 6),
        Position(row: 2, col: 1),
        Position(row: 3, col: 5),
        Position(row: 4, col: 2),
        Position(row: 5, col: 0),
        Position(row: 6, col: 4),
        Position(row: 7, col: 7),
    ]

    func testBundledPuzzle001SolutionMatchesUITestFixture() throws {
        let puzzle = try PuzzleLoader().load(named: "puzzle-001")
        XCTAssertEqual(puzzle.solution, Self.uiTestFixtureSolution)
    }
}
