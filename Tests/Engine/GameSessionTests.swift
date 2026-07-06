import XCTest
@testable import AnimalDoku

final class GameSessionTests: XCTestCase {
    func testInitCreatesEmptyBoardWithCorrectRegionIds() {
        let puzzle = make8x8Puzzle()
        let session = GameSession(puzzle: puzzle)

        XCTAssertEqual(session.cells.count, 64)
        XCTAssertTrue(session.cells.allSatisfy { $0.state == .empty })

        for row in 0..<8 {
            for col in 0..<8 {
                let position = Position(row: row, col: col)
                XCTAssertEqual(session.cell(at: position).regionId, row)
            }
        }
    }

    func testFreshSessionDefaults() {
        let session = GameSession(puzzle: make8x8Puzzle())

        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.elapsedSeconds, 0)
        XCTAssertTrue(session.undoStack.isEmpty)
        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertEqual(session.inputMode, .place)
        XCTAssertFalse(session.completed)
    }

    func testValidationResultReflectsBoardState() {
        let puzzle = make8x8Puzzle()
        let session = GameSession(puzzle: puzzle)

        XCTAssertTrue(session.validationResult.isValid)
        XCTAssertFalse(session.validationResult.isComplete)
        XCTAssertTrue(session.validationResult.violations.isEmpty)

        session.tap(at: Position(row: 0, col: 0))
        session.tap(at: Position(row: 0, col: 1))

        XCTAssertFalse(session.validationResult.isValid)
        XCTAssertFalse(session.validationResult.isComplete)
        XCTAssertEqual(session.validationResult.violations.first?.rule, .row)
    }

    func testPuzzleRemainsImmutable() {
        let puzzle = make8x8Puzzle()
        let session = GameSession(puzzle: puzzle)

        session.tap(at: Position(row: 0, col: 0))

        XCTAssertEqual(session.puzzle, puzzle)
        XCTAssertTrue(session.puzzle.solution.isEmpty)
    }

    // MARK: - P3.2 Place / Remove / Block

    func testPlaceModeTapEmptyPlacesAnimal() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.undoStack.count, 1)
        XCTAssertEqual(session.undoStack.last, .place(at: position, previous: .empty))
    }

    func testPlaceModeTapAnimalRemovesAnimal() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertEqual(session.undoStack.count, 2)
        XCTAssertEqual(session.undoStack.last, .remove(at: position, previous: .animal))
    }

    func testPlaceModeTapBlockedHasNoEffect() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let position = Position(row: 0, col: 0)

        session.inputMode = .mark
        session.tap(at: position)
        session.inputMode = .place
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .blocked)
        XCTAssertEqual(session.undoStack.count, 1)
    }

    func testMarkModeTogglesBlockedMark() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let position = Position(row: 1, col: 1)

        session.inputMode = .mark
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .blocked)

        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertEqual(session.undoStack.count, 2)
    }

    func testMarkModeTapAnimalHasNoEffect() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let position = Position(row: 2, col: 2)

        session.tap(at: position)
        session.inputMode = .mark
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.undoStack.count, 1)
    }

    func testConflictingPlacementsSurfaceRowViolation() {
        let session = GameSession(puzzle: make8x8Puzzle())

        session.tap(at: Position(row: 0, col: 0))
        session.tap(at: Position(row: 0, col: 1))

        XCTAssertFalse(session.validationResult.isValid)
        XCTAssertEqual(session.validationResult.violations.first?.rule, .row)
        XCTAssertEqual(
            session.validationResult.violations.first?.positions,
            [Position(row: 0, col: 0), Position(row: 0, col: 1)]
        )
    }

    func testCompletedBoardRejectsTaps() throws {
        let puzzle = try PuzzleLoader().load(named: "puzzle-valid-4x4")
        let session = GameSession(puzzle: puzzle)

        for position in puzzle.solution {
            session.tap(at: position)
        }

        XCTAssertTrue(session.completed)

        let target = Position(row: 3, col: 3)
        session.tap(at: target)

        XCTAssertEqual(session.cell(at: target).state, .empty)
        XCTAssertEqual(session.undoStack.count, 4)
    }

    func testNewActionClearsRedoStack() {
        let session = GameSession(puzzle: make8x8Puzzle())
        let first = Position(row: 0, col: 0)
        let second = Position(row: 1, col: 0)

        session.tap(at: first)
        session.undo()
        XCTAssertEqual(session.redoStack.count, 1)

        session.tap(at: second)

        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertEqual(session.undoStack.count, 1)
        XCTAssertEqual(session.undoStack.last, .place(at: second, previous: .empty))
    }

    func testBundledPuzzleStartsIncomplete() throws {
        let puzzle = try PuzzleLoader().load(named: "puzzle-valid-4x4")
        let session = GameSession(puzzle: puzzle)

        XCTAssertEqual(session.cells.count, 16)
        XCTAssertFalse(session.validationResult.isComplete)
    }

    private func make8x8Puzzle() -> Puzzle {
        let regions = (0..<8).map { row in
            Region(
                id: row,
                color: "#A8D8EA",
                cells: (0..<8).map { col in Position(row: row, col: col) }
            )
        }

        return Puzzle(
            id: "test-8x8",
            size: 8,
            regions: regions,
            solution: [],
            difficulty: .easy,
            initialPlacements: []
        )
    }
}
