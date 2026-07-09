import Observation
import SwiftUI

/// Primary game screen composing board, mode toggle, and toolbar (v0.1 playable milestone).
struct GameView: View {
    @State private var viewModel: GameViewModel

    init(puzzle: Puzzle) {
        _viewModel = State(initialValue: GameViewModel(puzzle: puzzle))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: AppSpacing.sm) {
            Text("Animal Doku")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)
                .accessibilityAddTraits(.isHeader)

            InputModeToggle(
                mode: $viewModel.inputMode,
                isEnabled: !viewModel.isCompleted
            )

            BoardView(
                puzzle: viewModel.puzzle,
                cells: viewModel.cells,
                validationResult: viewModel.validationResult,
                selectedPosition: viewModel.selectedPosition,
                isBoardLocked: viewModel.isCompleted,
                animalIcon: ThemeAsset.image(for: "frogs"),
                onCellTap: { viewModel.handleCellTap(at: $0) }
            )

            GameToolbar(
                canUndo: viewModel.canUndo,
                canRedo: viewModel.canRedo,
                canReset: viewModel.canReset,
                canHint: viewModel.canHint,
                hintsRemaining: viewModel.hintsRemaining,
                isEnabled: !viewModel.isCompleted,
                onUndo: { viewModel.undo() },
                onRedo: { viewModel.redo() },
                onReset: { viewModel.reset() },
                onHint: { viewModel.requestHint() }
            )
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .sheet(isPresented: $viewModel.showWinScreen) {
            WinScreen {
                viewModel.playAgain()
            }
            .interactiveDismissDisabled()
        }
    }
}

#if DEBUG
#Preview {
    GameView(puzzle: BoardPreviewPuzzle.mini)
}

private enum BoardPreviewPuzzle {
    static let mini = Puzzle(
        id: "preview-4x4",
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
#endif
