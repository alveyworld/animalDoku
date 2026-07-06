import XCTest
@testable import AnimalDoku

final class ValidatorValidateTests: XCTestCase {
    private let validator = Validator()
    private let loader = PuzzleLoader()

    func testRowViolationInValidateResult() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 2, regionId: 1, state: .animal),
        ]
        let puzzle = makePuzzle(size: 4)

        let result = validator.validate(cells: cells, puzzle: puzzle)

        XCTAssertFalse(result.isValid)
        XCTAssertFalse(result.isComplete)
        XCTAssertEqual(result.violations.count, 1)
        XCTAssertEqual(result.violations[0].rule, .row)
        XCTAssertEqual(
            result.violations[0].positions,
            [Position(row: 0, col: 0), Position(row: 0, col: 2)]
        )
    }

    func testAdjacencyViolationInValidateResult() {
        let cells = [
            Cell(row: 1, col: 1, regionId: 0, state: .animal),
            Cell(row: 2, col: 2, regionId: 1, state: .animal),
        ]
        let puzzle = makePuzzle(size: 4)

        let result = validator.validate(cells: cells, puzzle: puzzle)

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.violations.contains { $0.rule == .adjacency })
    }

    func testSolutionBoardIsValidAndComplete() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let cells = makeBoardCells(puzzle: puzzle, animalPositions: Set(puzzle.solution))

        let result = validator.validate(cells: cells, puzzle: puzzle)

        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.isComplete)
        XCTAssertTrue(result.violations.isEmpty)
    }

    func testMultipleSimultaneousViolationsAreAggregated() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 1, regionId: 0, state: .animal),
        ]
        let puzzle = makePuzzle(size: 2)

        let result = validator.validate(cells: cells, puzzle: puzzle)
        let rules = Set(result.violations.map(\.rule))

        XCTAssertFalse(result.isValid)
        XCTAssertGreaterThanOrEqual(result.violations.count, 2)
        XCTAssertTrue(rules.contains(.row))
        XCTAssertTrue(rules.contains(.region))
    }

    func testValidateDoesNotMutateCells() {
        var cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 1, regionId: 1, state: .animal),
        ]
        let puzzle = makePuzzle(size: 2)
        let before = cells

        _ = validator.validate(cells: cells, puzzle: puzzle)

        XCTAssertEqual(cells, before)
        XCTAssertEqual(cells[0].state, .animal)
        XCTAssertEqual(cells[1].state, .animal)
    }

    func testValidationResultsAreEquatable() throws {
        let puzzle = try loader.load(named: "puzzle-valid-4x4")
        let cells = makeBoardCells(puzzle: puzzle, animalPositions: Set(puzzle.solution))

        let first = validator.validate(cells: cells, puzzle: puzzle)
        let second = validator.validate(cells: cells, puzzle: puzzle)

        XCTAssertEqual(first, second)
    }

    private func makePuzzle(size: Int) -> Puzzle {
        Puzzle(
            id: "test-\(size)",
            size: size,
            regions: (0..<size).map { id in
                Region(id: id, color: "#A8D8EA", cells: [])
            },
            solution: [],
            difficulty: .easy,
            initialPlacements: []
        )
    }

    private func makeBoardCells(puzzle: Puzzle, animalPositions: Set<Position>) -> [Cell] {
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
