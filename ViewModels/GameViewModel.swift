import Observation

/// Observable bridge between SwiftUI and `GameSession`.
///
/// Delegates all game logic to the engine; this type only exposes state for binding
/// and routes user intents to session methods.
@Observable
final class GameViewModel {
    private let session: GameSession

    var selectedPosition: Position?
    var showWinScreen = false
    private(set) var cells: [Cell] = []
    private(set) var validationResult = ValidationResult(
        isValid: true,
        isComplete: false,
        violations: []
    )

    var inputMode: InputMode {
        get { session.inputMode }
        set {
            session.inputMode = newValue
            publishChanges()
        }
    }

    var puzzle: Puzzle { session.puzzle }
    var isCompleted: Bool { session.completed }
    var hintsUsed: Int { session.hintsUsed }
    var canUndo: Bool { session.canUndo }
    var canRedo: Bool { session.canRedo }
    var canReset: Bool { !session.completed }
    var canHint: Bool { session.canHint(selected: selectedPosition) }
    var hintsRemaining: Int { session.hintsRemaining }
    var violatingPositions: Set<Position> {
        Set(validationResult.violations.flatMap(\.positions))
    }

    init(puzzle: Puzzle) {
        self.session = GameSession(puzzle: puzzle)
        publishChanges()
    }

    init(session: GameSession) {
        self.session = session
        publishChanges()
    }

    func handleCellTap(at position: Position) {
        guard !session.completed else { return }

        selectedPosition = position
        session.tap(at: position)
        publishChanges()
        checkWinState()
    }

    func undo() {
        session.undo()
        publishChanges()
        checkWinState()
    }

    func redo() {
        session.redo()
        publishChanges()
        checkWinState()
    }

    func reset() {
        session.reset()
        selectedPosition = nil
        showWinScreen = false
        publishChanges()
    }

    /// Resets after a win and returns to default Place mode (P3.15 AC-7).
    func playAgain() {
        reset()
        inputMode = .place
    }

    func requestHint() {
        _ = session.requestHint(selected: selectedPosition)
        publishChanges()
        checkWinState()
    }

    func dismissWinScreen() {
        showWinScreen = false
    }

    private func checkWinState() {
        if session.validationResult.isComplete {
            showWinScreen = true
        }
    }

    private func publishChanges() {
        cells = session.cells
        validationResult = session.validationResult
    }
}
