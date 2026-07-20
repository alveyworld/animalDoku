import Observation
import SwiftUI

/// Primary game screen composing board and toolbar.
struct GameView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(SoundService.self) private var soundService
    @Environment(HapticService.self) private var hapticService
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: GameViewModel
    @State private var showSettings = false
    @State private var didAttachServices = false

    init(puzzle: Puzzle, saveStore: SaveGamePersisting = InMemorySaveGameStore()) {
        _viewModel = State(initialValue: GameViewModel(puzzle: puzzle, saveStore: saveStore))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        let theme = settings.selectedTheme
        let highContrast = settings.highContrastEnabled

        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("Animal Doku")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.resolvedPrimary(highContrast: highContrast))
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AppColors.resolvedPrimary(highContrast: highContrast))
                        .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(SettingsViewAccessibility.openSettingsLabel)
                .accessibilityHint(SettingsViewAccessibility.openSettingsHint)
                .accessibilityIdentifier("openSettingsButton")
                .accessibilityAddTraits(.isButton)
            }

            Text(GameViewAccessibility.gestureHint)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.resolvedSecondary(highContrast: highContrast))
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHidden(true)

            BoardView(
                puzzle: viewModel.puzzle,
                cells: viewModel.cells,
                validationResult: viewModel.validationResult,
                selectedPosition: viewModel.selectedPosition,
                isBoardLocked: viewModel.isCompleted,
                theme: theme,
                onCellSingleTap: { viewModel.handleCellSingleTap(at: $0) },
                onCellDoubleTap: { viewModel.handleCellDoubleTap(at: $0) },
                onMarkDragBegan: { viewModel.beginMarkDrag(at: $0) },
                onMarkDragMoved: { viewModel.continueMarkDrag(at: $0) },
                onMarkDragEnded: { viewModel.endMarkDrag() }
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
        .background(AppColors.resolvedBackground(highContrast: highContrast))
        .environment(\.highContrast, highContrast)
        .onAppear {
            guard !didAttachServices else { return }
            viewModel.soundService = soundService
            viewModel.hapticService = hapticService
            didAttachServices = true
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                viewModel.resumeTimer()
            case .inactive, .background:
                viewModel.pauseTimer()
            @unknown default:
                break
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(\.highContrast, highContrast)
        }
        .sheet(isPresented: $viewModel.showWinScreen) {
            WinScreen(elapsedSeconds: viewModel.elapsedSeconds) {
                viewModel.playAgain()
            }
            .environment(\.highContrast, highContrast)
            .interactiveDismissDisabled()
        }
    }
}

enum GameViewAccessibility {
    static let gestureHint = String(
        localized: "game.gestureHint",
        defaultValue: "Tap to mark · Double-tap to place"
    )
}

#if DEBUG
#Preview {
    let settings = SettingsStore()
    return GameView(puzzle: BoardPreviewPuzzle.mini)
        .environment(settings)
        .environment(SoundService(settings: settings))
        .environment(HapticService(settings: settings))
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
