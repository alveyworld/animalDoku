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

    func testPlaceModeTapPlacesAnimal() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.inputMode = .place
        viewModel.handleCellTap(at: position)

        XCTAssertEqual(viewModel.cellState(at: position), .animal)
    }

    func testMarkModeTapBlocksCell() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.inputMode = .mark
        viewModel.handleCellTap(at: position)

        XCTAssertEqual(viewModel.cellState(at: position), .blocked)
    }

    func testUndoRestoresPriorStateAndEnablesRedo() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 0, col: 0)

        viewModel.inputMode = .place
        viewModel.handleCellTap(at: position)
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
        viewModel.handleCellTap(at: emptyPosition)

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

        viewModel.inputMode = .place
        viewModel.handleCellTap(at: first)
        viewModel.handleCellTap(at: second)

        XCTAssertTrue(viewModel.violatingPositions.contains(first))
        XCTAssertTrue(viewModel.violatingPositions.contains(second))
    }

    func testHandleCellTapUpdatesSelectedPosition() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        let position = Position(row: 1, col: 2)

        viewModel.handleCellTap(at: position)

        XCTAssertEqual(viewModel.selectedPosition, position)
    }

    func testCanResetDisabledWhenCompleted() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        solve(viewModel)

        XCTAssertFalse(viewModel.canReset)
    }

    func testPartialBoardDoesNotShowWinScreen() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())

        viewModel.handleCellTap(at: Position(row: 0, col: 1))

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
    }

    func testInvalidFullBoardDoesNotShowWinScreen() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        viewModel.inputMode = .place

        for position in [
            Position(row: 0, col: 0),
            Position(row: 1, col: 0),
            Position(row: 2, col: 2),
            Position(row: 3, col: 3),
        ] {
            viewModel.handleCellTap(at: position)
        }

        XCTAssertFalse(viewModel.validationResult.isComplete)
        XCTAssertFalse(viewModel.showWinScreen)
    }

    func testPlayAgainResetsSessionAndReturnsToPlaceMode() {
        let viewModel = GameViewModel(puzzle: TestPuzzleFactory.miniPuzzle())
        viewModel.inputMode = .mark
        solve(viewModel)

        viewModel.playAgain()

        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertFalse(viewModel.showWinScreen)
        XCTAssertEqual(viewModel.inputMode, .place)
        XCTAssertEqual(viewModel.hintsUsed, 0)
        XCTAssertFalse(viewModel.canUndo)
        XCTAssertFalse(viewModel.canRedo)
        XCTAssertTrue(viewModel.cells.allSatisfy { $0.state == .empty })
    }

    // MARK: - Helpers

    private func solve(_ viewModel: GameViewModel) {
        viewModel.inputMode = .place
        for position in viewModel.puzzle.solution {
            viewModel.handleCellTap(at: position)
        }
    }
}

private extension GameViewModel {
    func cellState(at position: Position) -> CellState {
        cells.first { $0.row == position.row && $0.col == position.col }?.state ?? .empty
    }
}
