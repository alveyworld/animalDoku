import XCTest
@testable import AnimalDoku

final class ValidatorCompletionTests: XCTestCase {
    private let validator = Validator()
    private let loader = PuzzleLoader()

    func testPartialBoardIsNotComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let partial = Set(puzzle.solution.prefix(2))
        let cells = Self.makeBoardCells(puzzle: puzzle, animalPositions: partial)

        XCTAssertFalse(validator.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size))
    }

    func testSolutionBoardIsComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let cells = Self.makeBoardCells(puzzle: puzzle, animalPositions: Set(puzzle.solution))

        XCTAssertTrue(validator.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size))
    }

    func testFullBoardWithViolationIsNotComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let invalidPlacements: Set<Position> = [
            Position(row: 0, col: 0),
            Position(row: 0, col: 1),
            Position(row: 2, col: 2),
            Position(row: 3, col: 3),
        ]
        let cells = Self.makeBoardCells(puzzle: puzzle, animalPositions: invalidPlacements)

        XCTAssertFalse(validator.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size))
    }

    func testValidFullBoardIsValidAndComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let cells = Self.makeBoardCells(puzzle: puzzle, animalPositions: Set(puzzle.solution))

        let isValid = validator.uniquenessViolations(cells: cells, size: puzzle.size).isEmpty
            && validator.adjacencyViolations(cells: cells, size: puzzle.size).isEmpty

        XCTAssertTrue(isValid)
        XCTAssertTrue(validator.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size))
    }

    func testEmptyBoardIsNotComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let cells = Self.makeBoardCells(puzzle: puzzle, animalPositions: [])

        XCTAssertFalse(validator.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size))
    }

    private static func makeBoardCells(puzzle: Puzzle, animalPositions: Set<Position>) -> [Cell] {
        puzzle.regions.flatMap { region in
            region.cells.map { position in
                Cell(
                    row: position.row,
                    col: position.col,
                    regionId: region.id,
                    state: animalPositions.contains(position) ? .animal : .empty
                )
            }
        }
    }
}
