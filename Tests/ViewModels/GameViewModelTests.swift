import XCTest
@testable import AnimalDoku

final class GameViewModelTests: XCTestCase {
    func testFreshSessionExposesEmptyCells() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.emptyGrid8x8())

        XCTAssertEqual(viewModel.cells.count, 64)
        XCTAssertTrue(viewModel.cells.allSatisfy { $0.state == .empty })
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
    }

    func testDoubleTapPlacesAnimal() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.handleCellDoubleTap(at: position)

        XCTAssertEqual(viewModel.cellState(at: position), .animal)
    }

    func testSingleTapBlocksCell() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.handleCellSingleTap(at: position)

        XCTAssertEqual(viewModel.cellState(at: position), .blocked)
    }

    func testUndoRestoresPriorStateAndEnablesRedo() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.handleCellDoubleTap(at: position)
        viewModel.undo()

        XCTAssertEqual(viewModel.cellState(at: position), .empty)
        XCTAssertTrue(viewModel.canRedo)
    }

    func testCompletingPuzzleShowsWinScreen() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())

        solve(viewModel)

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertTrue(viewModel.showWinScreen)
    }

    func testCompletedBoardRejectsTaps() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        solve(viewModel)

        let emptyPosition = Position(row: 0, col: 0)
        viewModel.handleCellDoubleTap(at: emptyPosition)
        viewModel.handleCellSingleTap(at: emptyPosition)

        XCTAssertEqual(viewModel.cellState(at: emptyPosition), .empty)
    }

    func testResetAfterCompletionClearsWinState() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        solve(viewModel)

        viewModel.reset()

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
        XCTAssertNil(viewModel.selectedPosition)
        XCTAssertTrue(viewModel.cells.allSatisfy { $0.state == .empty })
    }

    func testViolatingPositionsIncludesAllViolationCells() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.emptyGrid8x8())
        let first = Position(row: 0, col: 0)
        let second = Position(row: 0, col: 1)

        viewModel.handleCellDoubleTap(at: first)
        viewModel.handleCellDoubleTap(at: second)

        XCTAssertTrue(viewModel.violatingPositions.contains(first))
        XCTAssertTrue(viewModel.violatingPositions.contains(second))
    }

    func testHandleCellSingleTapUpdatesSelectedPosition() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 1, col: 2)

        viewModel.handleCellSingleTap(at: position)

        XCTAssertEqual(viewModel.selectedPosition, position)
    }

    func testCanResetDisabledWhenCompleted() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        solve(viewModel)

        XCTAssertFalse(viewModel.canReset)
    }

    func testPartialBoardDoesNotShowWinScreen() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 1))

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
    }

    func testInvalidFullBoardDoesNotShowWinScreen() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())

        for position in [
            Position(row: 0, col: 0),
            Position(row: 1, col: 0),
            Position(row: 2, col: 2),
            Position(row: 3, col: 3),
        ] {
            viewModel.handleCellDoubleTap(at: position)
        }

        XCTAssertFalse(viewModel.validationResult.isComplete)
        XCTAssertFalse(viewModel.showWinScreen)
    }

    func testPlayAgainResetsSession() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        viewModel.handleCellSingleTap(at: Position(row: 0, col: 0))
        solve(viewModel)

        viewModel.playAgain()

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
        XCTAssertEqual(viewModel.hintsUsed, 0)
        XCTAssertFalse(viewModel.canUndo)
        XCTAssertFalse(viewModel.canRedo)
        XCTAssertTrue(viewModel.cells.allSatisfy { $0.state == .empty })
    }

    func testPlaceTapPlaysPlaceSound() {
        let sound = RecordingSoundService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            soundService: sound
        )

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))

        XCTAssertEqual(sound.played, [.place])
    }

    func testRemoveTapPlaysRemoveSound() {
        let sound = RecordingSoundService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            soundService: sound
        )
        let position = Position(row: 0, col: 0)

        viewModel.handleCellDoubleTap(at: position)
        sound.reset()
        viewModel.handleCellDoubleTap(at: position)

        XCTAssertEqual(sound.played, [.remove])
    }

    func testMarkSingleTapDoesNotPlaySound() {
        let sound = RecordingSoundService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            soundService: sound
        )

        viewModel.handleCellSingleTap(at: Position(row: 0, col: 0))

        XCTAssertTrue(sound.played.isEmpty)
    }

    func testCompletingPuzzlePlaysWinSoundOnce() {
        let sound = RecordingSoundService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            soundService: sound
        )

        solve(viewModel)

        XCTAssertEqual(sound.played.last, .win)
        XCTAssertEqual(sound.played.filter { $0 == .win }.count, 1)
    }

    func testDisabledRecordingServiceDoesNotPlayFromViewModel() {
        let sound = RecordingSoundService()
        sound.isEnabled = false
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            soundService: sound
        )

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))

        XCTAssertTrue(sound.played.isEmpty)
    }

    func testTimerSyncedToSessionAndStopsOnWin() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            timerService: timer
        )

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))
        clock.advance(4)
        timer.tick()
        viewModel.pauseTimer()
        XCTAssertEqual(viewModel.elapsedSeconds, 4)

        clock.advance(10)
        viewModel.resumeTimer()
        clock.advance(2)
        timer.tick()
        viewModel.pauseTimer()
        XCTAssertEqual(viewModel.elapsedSeconds, 6)

        // Clear off-solution placement so solve can place cleanly.
        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))
        solve(viewModel)
        let finished = viewModel.elapsedSeconds
        clock.advance(30)
        timer.tick()
        viewModel.resumeTimer()
        XCTAssertEqual(viewModel.elapsedSeconds, finished)
        XCTAssertTrue(viewModel.showWinScreen)
    }

    func testResetZerosElapsedSeconds() {
        let clock = FakeClock()
        let timer = TimerService(clock: clock)
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            timerService: timer
        )

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))
        clock.advance(8)
        viewModel.pauseTimer()
        XCTAssertEqual(viewModel.elapsedSeconds, 8)

        viewModel.reset()
        XCTAssertEqual(viewModel.elapsedSeconds, 0)
    }

    // MARK: - P5.7 Mark drag

    func testMarkDragPaintsEmptyCellsWithOneUndoStep() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let cells = [
            Position(row: 0, col: 0),
            Position(row: 0, col: 1),
            Position(row: 0, col: 2),
        ]

        viewModel.beginMarkDrag(at: cells[0])
        viewModel.continueMarkDrag(at: cells[1])
        viewModel.continueMarkDrag(at: cells[2])
        viewModel.endMarkDrag()

        for position in cells {
            XCTAssertEqual(viewModel.cellState(at: position), .blocked)
        }

        viewModel.undo()
        for position in cells {
            XCTAssertEqual(viewModel.cellState(at: position), .empty)
        }
        XCTAssertTrue(viewModel.canRedo)
    }

    func testMarkDragClearsBlockedCells() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let cells = [
            Position(row: 1, col: 0),
            Position(row: 1, col: 1),
        ]

        for position in cells {
            viewModel.handleCellSingleTap(at: position)
        }

        viewModel.beginMarkDrag(at: cells[0])
        viewModel.continueMarkDrag(at: cells[1])
        viewModel.endMarkDrag()

        for position in cells {
            XCTAssertEqual(viewModel.cellState(at: position), .empty)
        }
    }

    func testMarkDragVisitsEachCellOnce() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.beginMarkDrag(at: position)
        viewModel.continueMarkDrag(at: position)
        viewModel.continueMarkDrag(at: position)
        viewModel.endMarkDrag()

        XCTAssertEqual(viewModel.cellState(at: position), .blocked)
        viewModel.undo()
        XCTAssertEqual(viewModel.cellState(at: position), .empty)
    }

    func testMarkDragSkipsAnimalWithoutEndingStroke() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let animal = Position(row: 0, col: 0)
        let empty = Position(row: 0, col: 1)

        viewModel.handleCellDoubleTap(at: animal)

        viewModel.beginMarkDrag(at: animal)
        viewModel.continueMarkDrag(at: empty)
        viewModel.endMarkDrag()

        XCTAssertEqual(viewModel.cellState(at: animal), .animal)
        XCTAssertEqual(viewModel.cellState(at: empty), .blocked)
    }

    func testBeginMarkDragWorksWithoutMode() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.beginMarkDrag(at: position)
        viewModel.continueMarkDrag(at: Position(row: 0, col: 1))
        viewModel.endMarkDrag()

        XCTAssertEqual(viewModel.cellState(at: position), .blocked)
        XCTAssertEqual(viewModel.cellState(at: Position(row: 0, col: 1)), .blocked)
        XCTAssertTrue(viewModel.canUndo)
    }

    func testMarkDragThenDoubleTapPlaceOnAnotherCell() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let marked = Position(row: 0, col: 0)
        let placeTarget = Position(row: 0, col: 2)

        viewModel.beginMarkDrag(at: marked)
        viewModel.endMarkDrag()

        viewModel.handleCellDoubleTap(at: placeTarget)

        XCTAssertEqual(viewModel.cellState(at: marked), .blocked)
        XCTAssertEqual(viewModel.cellState(at: placeTarget), .animal)
    }

    func testMarkDragNoOpsWhenCompleted() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        solve(viewModel)
        let cellsBefore = viewModel.cells

        viewModel.beginMarkDrag(at: Position(row: 0, col: 0))
        viewModel.continueMarkDrag(at: Position(row: 0, col: 2))
        viewModel.endMarkDrag()

        XCTAssertEqual(viewModel.cells, cellsBefore)
        XCTAssertEqual(viewModel.cellState(at: Position(row: 0, col: 0)), .empty)
    }

    func testMarkDragPlaysHapticOnceAtStrokeStart() {
        let haptics = RecordingHapticService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            hapticService: haptics
        )

        viewModel.beginMarkDrag(at: Position(row: 0, col: 0))
        viewModel.continueMarkDrag(at: Position(row: 0, col: 1))
        viewModel.continueMarkDrag(at: Position(row: 0, col: 2))
        viewModel.endMarkDrag()

        XCTAssertEqual(haptics.played, [.place])
    }

    // MARK: - Helpers

    private func solve(_ viewModel: GameViewModel) {
        for position in viewModel.puzzle.solution {
            viewModel.handleCellDoubleTap(at: position)
        }
    }
}

private extension GameViewModel {
    func cellState(at position: Position) -> CellState {
        cells.first { $0.row == position.row && $0.col == position.col }?.state ?? .empty
    }
}
