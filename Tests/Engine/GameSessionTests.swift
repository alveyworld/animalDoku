import XCTest
@testable import AnimalDoku

/// GameSession engine tests (P3.1–P3.6).
///
/// Formal Rules coverage map:
/// - Interaction Model table (Place/Mark × cell state) — P3.2
/// - AC-H.1–H.3 (hint limit, blocked rejection, first hint) — P3.6
/// - Undo / redo / reset player actions — P3.3–P3.5
/// - Rule 5 completion via scripted solve — AC-4
final class GameSessionTests: XCTestCase {
    func testInitCreatesEmptyBoardWithCorrectRegionIds() {
        let puzzle = TestPuzzleFactory.emptyGrid8x8()
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
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())

        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.elapsedSeconds, 0)
        XCTAssertTrue(session.undoStack.isEmpty)
        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertEqual(session.inputMode, .place)
        XCTAssertFalse(session.completed)
    }

    func testValidationResultReflectsBoardState() {
        let puzzle = TestPuzzleFactory.emptyGrid8x8()
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
        let puzzle = TestPuzzleFactory.emptyGrid8x8()
        let session = GameSession(puzzle: puzzle)

        session.tap(at: Position(row: 0, col: 0))

        XCTAssertEqual(session.puzzle, puzzle)
        XCTAssertTrue(session.puzzle.solution.isEmpty)
    }

    // MARK: - P3.2 Place / Remove / Block

    func testPlaceModeTapEmptyPlacesAnimal() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.undoStack.count, 1)
        XCTAssertEqual(session.undoStack.last, .place(at: position, previous: .empty))
    }

    func testPlaceModeTapAnimalRemovesAnimal() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertEqual(session.undoStack.count, 2)
        XCTAssertEqual(session.undoStack.last, .remove(at: position, previous: .animal))
    }

    func testPlaceModeTapBlockedHasNoEffect() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 0, col: 0)

        session.inputMode = .mark
        session.tap(at: position)
        session.inputMode = .place
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .blocked)
        XCTAssertEqual(session.undoStack.count, 1)
    }

    func testMarkModeTogglesBlockedMark() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 1, col: 1)

        session.inputMode = .mark
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .blocked)

        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertEqual(session.undoStack.count, 2)
    }

    func testMarkModeTapAnimalHasNoEffect() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 2, col: 2)

        session.tap(at: position)
        session.inputMode = .mark
        session.tap(at: position)

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.undoStack.count, 1)
    }

    func testConflictingPlacementsSurfaceRowViolation() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())

        session.tap(at: Position(row: 0, col: 0))
        session.tap(at: Position(row: 0, col: 1))

        XCTAssertFalse(session.validationResult.isValid)
        XCTAssertEqual(session.validationResult.violations.first?.rule, .row)
        XCTAssertEqual(
            session.validationResult.violations.first?.positions,
            [Position(row: 0, col: 0), Position(row: 0, col: 1)]
        )
    }

    func testCompletedBoardRejectsTaps() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
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
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
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

    // MARK: - P3.3 Undo

    func testUndoPlaceRestoresEmptyCell() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)
        session.undo()

        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertTrue(session.undoStack.isEmpty)
        XCTAssertEqual(session.redoStack.last, .place(at: position, previous: .empty))
        XCTAssertFalse(session.canUndo)
    }

    func testUndoOnEmptyStackIsNoOp() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let initialCells = session.cells

        session.undo()

        XCTAssertEqual(session.cells, initialCells)
        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertFalse(session.canUndo)
    }

    func testSequentialUndosRestoreInitialBoard() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let initialCells = session.cells

        session.tap(at: Position(row: 0, col: 0))
        session.inputMode = .mark
        session.tap(at: Position(row: 1, col: 1))
        session.tap(at: Position(row: 2, col: 2))

        session.undo()
        session.undo()
        session.undo()

        XCTAssertEqual(session.cells, initialCells)
        XCTAssertEqual(session.redoStack.count, 3)
    }

    func testUndoRemoveRestoresAnimal() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 3, col: 3)

        session.tap(at: position)
        session.tap(at: position)
        session.undo()

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.redoStack.last, .remove(at: position, previous: .animal))
    }

    func testUndoToggleBlockedRestoresPreviousState() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 4, col: 4)

        session.inputMode = .mark
        session.tap(at: position)
        session.undo()

        XCTAssertEqual(session.cell(at: position).state, .empty)

        session.tap(at: position)
        session.tap(at: position)
        session.undo()

        XCTAssertEqual(session.cell(at: position).state, .blocked)
    }

    func testUndoHintDecrementsHintsUsed() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 5, col: 5)

        session.apply(.hint(at: position, previous: .empty))

        XCTAssertEqual(session.hintsUsed, 1)
        XCTAssertEqual(session.cell(at: position).state, .animal)

        session.undo()

        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.cell(at: position).state, .empty)
        XCTAssertEqual(session.redoStack.last, .hint(at: position, previous: .empty))
    }

    func testUndoRevalidatesBoard() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())

        session.tap(at: Position(row: 0, col: 0))
        session.tap(at: Position(row: 0, col: 1))
        XCTAssertFalse(session.validationResult.isValid)

        session.undo()

        XCTAssertTrue(session.validationResult.isValid)
        XCTAssertFalse(session.validationResult.isComplete)
        XCTAssertTrue(session.validationResult.violations.isEmpty)
    }

    func testUndoAllowedWhenBoardCompleted() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        for position in puzzle.solution {
            session.tap(at: position)
        }

        XCTAssertTrue(session.completed)

        session.undo()

        XCTAssertFalse(session.completed)
        XCTAssertEqual(session.undoStack.count, 3)
        XCTAssertEqual(session.redoStack.count, 1)
    }

    // MARK: - P3.4 Redo

    func testRedoPlaceRestoresAnimal() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 0, col: 0)

        session.tap(at: position)
        session.undo()
        session.redo()

        XCTAssertEqual(session.cell(at: position).state, .animal)
        XCTAssertEqual(session.undoStack.last, .place(at: position, previous: .empty))
        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertTrue(session.canUndo)
    }

    func testRedoOnEmptyStackIsNoOp() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let initialCells = session.cells

        session.redo()

        XCTAssertEqual(session.cells, initialCells)
        XCTAssertFalse(session.canRedo)
    }

    func testRedoHintIncrementsHintsUsed() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 5, col: 5)

        session.apply(.hint(at: position, previous: .empty))
        session.undo()
        session.redo()

        XCTAssertEqual(session.hintsUsed, 1)
        XCTAssertEqual(session.cell(at: position).state, .animal)
    }

    func testUndoThenRedoRoundTrip() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let position = Position(row: 2, col: 3)

        session.tap(at: position)
        let beforeUndo = session.cells

        session.undo()
        session.redo()

        XCTAssertEqual(session.cells, beforeUndo)
    }

    func testSequentialRedosPreserveRemainingHistory() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let first = Position(row: 0, col: 0)
        let second = Position(row: 1, col: 0)

        session.tap(at: first)
        session.tap(at: second)
        session.undo()
        session.undo()

        XCTAssertEqual(session.redoStack.count, 2)

        session.redo()

        XCTAssertEqual(session.cell(at: first).state, .animal)
        XCTAssertEqual(session.cell(at: second).state, .empty)
        XCTAssertEqual(session.redoStack.count, 1)

        session.redo()

        XCTAssertEqual(session.cell(at: second).state, .animal)
        XCTAssertTrue(session.redoStack.isEmpty)
    }

    func testRedoRecompletesBoard() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        for position in puzzle.solution {
            session.tap(at: position)
        }

        session.undo()
        XCTAssertFalse(session.completed)

        session.redo()
        XCTAssertTrue(session.completed)
    }

    // MARK: - P3.5 Reset

    func testResetClearsBoardHistoryAndCounters() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())

        session.tap(at: Position(row: 0, col: 0))
        session.inputMode = .mark
        session.tap(at: Position(row: 1, col: 1))
        session.apply(.hint(at: Position(row: 2, col: 2), previous: .empty))
        session.undo()

        session.reset()

        XCTAssertTrue(session.cells.allSatisfy { $0.state == .empty })
        XCTAssertTrue(session.undoStack.isEmpty)
        XCTAssertTrue(session.redoStack.isEmpty)
        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.elapsedSeconds, 0)
        XCTAssertFalse(session.completed)
        XCTAssertTrue(session.validationResult.isValid)
    }

    func testResetUnlocksCompletedBoard() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        for position in puzzle.solution {
            session.tap(at: position)
        }

        XCTAssertTrue(session.completed)

        session.reset()

        XCTAssertFalse(session.completed)

        let target = Position(row: 3, col: 3)
        session.tap(at: target)

        XCTAssertEqual(session.cell(at: target).state, .animal)
    }

    func testResetPreservesPuzzleAndInputMode() {
        let puzzle = TestPuzzleFactory.emptyGrid8x8()
        let session = GameSession(puzzle: puzzle)

        session.inputMode = .mark
        session.tap(at: Position(row: 0, col: 0))
        session.reset()

        XCTAssertEqual(session.puzzle, puzzle)
        XCTAssertEqual(session.inputMode, .mark)
    }

    func testResetIsIdempotent() {
        let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())

        session.tap(at: Position(row: 0, col: 0))
        session.reset()
        let afterFirstReset = session.cells

        session.reset()

        XCTAssertEqual(session.cells, afterFirstReset)
        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.elapsedSeconds, 0)
    }

    // MARK: - P3.6 Hints

    func testRequestHintRevealsFirstSolutionCell() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        XCTAssertTrue(session.requestHint())

        XCTAssertEqual(session.cell(at: Position(row: 0, col: 1)).state, .animal)
        XCTAssertEqual(session.hintsUsed, 1)
        XCTAssertEqual(session.hintsRemaining, 2)
        XCTAssertEqual(session.undoStack.last, .hint(at: Position(row: 0, col: 1), previous: .empty))
    }

    func testRequestHintUsesSelectedCell() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)
        let selected = Position(row: 3, col: 2)

        XCTAssertTrue(session.requestHint(selected: selected))

        XCTAssertEqual(session.cell(at: selected).state, .animal)
    }

    func testRequestHintRejectedAtMaxHints() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        XCTAssertTrue(session.requestHint())
        XCTAssertTrue(session.requestHint())
        XCTAssertTrue(session.requestHint())
        XCTAssertFalse(session.canHint())

        let hintsBefore = session.hintsUsed
        XCTAssertFalse(session.requestHint())
        XCTAssertEqual(session.hintsUsed, hintsBefore)
    }

    func testRequestHintRejectedOnBlockedCell() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)
        let blocked = Position(row: 0, col: 1)

        session.inputMode = .mark
        session.tap(at: blocked)

        XCTAssertFalse(session.requestHint(selected: blocked))
        XCTAssertEqual(session.hintsUsed, 0)
    }

    func testRequestHintRejectedWhenCompleted() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        for position in puzzle.solution {
            session.tap(at: position)
        }

        XCTAssertFalse(session.requestHint())
    }

    func testHintUndoDecrementsCounter() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)

        session.requestHint()
        session.undo()

        XCTAssertEqual(session.hintsUsed, 0)
        XCTAssertEqual(session.cell(at: Position(row: 0, col: 1)).state, .empty)
    }

    // MARK: - P3.7 Consolidated coverage

    func testInteractionMatrixTableDriven() {
        let position = Position(row: 2, col: 2)

        struct MatrixCase {
            let name: String
            let mode: InputMode
            let setup: (GameSession) -> Void
            let expectedState: CellState
            let recordsAction: Bool
        }

        let cases: [MatrixCase] = [
            MatrixCase(name: "place-empty", mode: .place, setup: { _ in }, expectedState: .animal, recordsAction: true),
            MatrixCase(name: "place-blocked", mode: .place, setup: { s in
                s.inputMode = .mark
                s.tap(at: position)
                s.inputMode = .place
            }, expectedState: .blocked, recordsAction: false),
            MatrixCase(name: "place-animal", mode: .place, setup: { s in
                s.tap(at: position)
            }, expectedState: .empty, recordsAction: true),
            MatrixCase(name: "mark-empty", mode: .mark, setup: { _ in }, expectedState: .blocked, recordsAction: true),
            MatrixCase(name: "mark-blocked", mode: .mark, setup: { s in
                s.inputMode = .mark
                s.tap(at: position)
            }, expectedState: .empty, recordsAction: true),
            MatrixCase(name: "mark-animal", mode: .mark, setup: { s in
                s.tap(at: position)
            }, expectedState: .animal, recordsAction: false),
        ]

        for testCase in cases {
            let session = GameSession(puzzle: TestPuzzleFactory.emptyGrid8x8())
            testCase.setup(session)
            let stackBefore = session.undoStack.count

            session.inputMode = testCase.mode
            session.tap(at: position)

            GameSessionTestHelpers.assertCellState(session, at: position, equals: testCase.expectedState)
            if testCase.recordsAction {
                XCTAssertEqual(session.undoStack.count, stackBefore + 1, testCase.name)
            } else {
                XCTAssertEqual(session.undoStack.count, stackBefore, testCase.name)
            }
        }
    }

    func testSolveViaPlacementsCompletesPuzzle() {
        let session = GameSession(puzzle: TestPuzzleFactory.miniPuzzle())

        GameSessionTestHelpers.solveViaPlacements(session)

        GameSessionTestHelpers.assertBoardMatchesSolution(session)
        XCTAssertTrue(session.completed)
        XCTAssertTrue(session.validationResult.isValid)
    }

    func testHintCompletesPuzzleWhenLastCellRemaining() {
        let session = GameSession(puzzle: TestPuzzleFactory.miniPuzzle())

        GameSessionTestHelpers.solveViaPlacements(session)
        session.undo()

        XCTAssertFalse(session.completed)

        XCTAssertTrue(session.requestHint())

        XCTAssertTrue(session.completed)
        GameSessionTestHelpers.assertBoardMatchesSolution(session)
    }

    func testBundledPuzzleStartsIncomplete() throws {
        let puzzle = try TestPuzzleFactory.loadBundledMini()
        let session = GameSession(puzzle: puzzle)

        XCTAssertEqual(session.cells.count, 16)
        XCTAssertFalse(session.validationResult.isComplete)
    }
}
