import Foundation
import Observation

/// Observable bridge between SwiftUI and `GameSession`.
///
/// Delegates all game logic to the engine; this type only exposes state for binding
/// and routes user intents to session methods.
@Observable
final class GameViewModel {
    private let session: GameSession

    @ObservationIgnored
    var soundService: SoundPlaying = NoOpSoundService()

    @ObservationIgnored
    var hapticService: HapticPlaying = NoOpHapticService()

    @ObservationIgnored
    private let timerService: TimerService

    @ObservationIgnored
    private let saveStore: SaveGamePersisting

    @ObservationIgnored
    private var tickTask: Task<Void, Never>?

    @ObservationIgnored
    private var markStroke: MarkDragStroke?

    var selectedPosition: Position?
    var showWinScreen = false
    private(set) var cells: [Cell] = []
    private(set) var validationResult = ValidationResult(
        isValid: true,
        isComplete: false,
        violations: []
    )

    var puzzle: Puzzle { session.puzzle }
    var isCompleted: Bool { session.completed }
    var hintsUsed: Int { session.hintsUsed }
    var elapsedSeconds: Int { session.elapsedSeconds }
    var canUndo: Bool { session.canUndo }
    var canRedo: Bool { session.canRedo }
    var canReset: Bool { !session.completed }
    var canHint: Bool { session.canHint(selected: selectedPosition) }
    var hintsRemaining: Int { session.hintsRemaining }
    var violatingPositions: Set<Position> {
        Set(validationResult.violations.flatMap(\.positions))
    }

    init(
        puzzle: Puzzle,
        soundService: SoundPlaying = NoOpSoundService(),
        hapticService: HapticPlaying = NoOpHapticService(),
        timerService: TimerService = TimerService(),
        saveStore: SaveGamePersisting = InMemorySaveGameStore()
    ) {
        self.session = GameSession(puzzle: puzzle)
        self.soundService = soundService
        self.hapticService = hapticService
        self.timerService = timerService
        self.saveStore = saveStore
        restoreIfNeeded()
        publishChanges()
    }

    init(
        session: GameSession,
        soundService: SoundPlaying = NoOpSoundService(),
        hapticService: HapticPlaying = NoOpHapticService(),
        timerService: TimerService = TimerService(),
        saveStore: SaveGamePersisting = InMemorySaveGameStore()
    ) {
        self.session = session
        self.soundService = soundService
        self.hapticService = hapticService
        self.timerService = timerService
        self.saveStore = saveStore
        restoreIfNeeded()
        publishChanges()
    }

    deinit {
        tickTask?.cancel()
    }

    // MARK: - Unified tap (P6.5)

    /// Single tap — toggle mark (X). Ignored while a mark-drag stroke is active.
    func handleCellSingleTap(at position: Position) {
        guard !session.completed else { return }
        guard markStroke == nil else { return }

        ensureTimerRunning()
        let previousState = session.cell(at: position).state
        selectedPosition = position
        session.toggleMark(at: position)
        let nextState = session.cell(at: position).state

        playFeedbackIfNeeded(from: previousState, to: nextState)
        publishChanges()
        checkWinState()
        persistSave()
    }

    /// Double tap — place animal (clearing mark if needed) or remove animal.
    func handleCellDoubleTap(at position: Position) {
        guard !session.completed else { return }
        guard markStroke == nil else { return }

        ensureTimerRunning()
        let previousState = session.cell(at: position).state
        selectedPosition = position
        session.placeOrRemove(at: position)
        let nextState = session.cell(at: position).state

        playFeedbackIfNeeded(from: previousState, to: nextState)
        publishChanges()
        checkWinState()
        persistSave()
    }

    // MARK: - Mark drag (P5.7)

    func beginMarkDrag(at position: Position) {
        guard !session.completed else { return }
        guard markStroke == nil else { return }

        ensureTimerRunning()
        markStroke = MarkDragStroke()
        selectedPosition = position
        applyMarkDragCell(at: position)
    }

    func continueMarkDrag(at position: Position) {
        guard markStroke != nil else { return }
        selectedPosition = position
        applyMarkDragCell(at: position)
    }

    func endMarkDrag() {
        guard let stroke = markStroke else { return }
        markStroke = nil

        if !stroke.changes.isEmpty {
            session.commitMarkStroke(stroke.changes)
            persistSave()
        }
        publishChanges()
        checkWinState()
    }

    private func applyMarkDragCell(at position: Position) {
        guard var stroke = markStroke else { return }
        guard stroke.visited.insert(position).inserted else {
            markStroke = stroke
            return
        }

        let current = session.cell(at: position).state

        if stroke.paintBlocked == nil {
            switch current {
            case .empty:
                stroke.paintBlocked = true
                hapticService.play(.place)
            case .blocked:
                stroke.paintBlocked = false
                hapticService.play(.place)
            case .animal:
                markStroke = stroke
                return
            }
        }

        guard let paintBlocked = stroke.paintBlocked else {
            markStroke = stroke
            return
        }

        if let previous = session.paintMark(at: position, paintBlocked: paintBlocked) {
            stroke.changes.append(MarkStrokeChange(at: position, previous: previous))
            publishChanges()
        }
        markStroke = stroke
    }

    func undo() {
        guard !session.completed else { return }
        markStroke = nil
        ensureTimerRunning()
        session.undo()
        publishChanges()
        checkWinState()
        persistSave()
    }

    func redo() {
        guard !session.completed else { return }
        markStroke = nil
        ensureTimerRunning()
        session.redo()
        publishChanges()
        checkWinState()
        persistSave()
    }

    func reset() {
        markStroke = nil
        stopTicking()
        timerService.reset()
        session.reset()
        selectedPosition = nil
        showWinScreen = false
        saveStore.clear(puzzleId: session.puzzle.id)
        publishChanges()
    }

    /// Resets after a win (P3.15).
    func playAgain() {
        reset()
    }

    func requestHint() {
        guard !session.completed else { return }
        ensureTimerRunning()

        let beforeHints = session.hintsUsed
        _ = session.requestHint(selected: selectedPosition)
        if session.hintsUsed > beforeHints {
            soundService.play(.place)
            hapticService.play(.place)
        }
        publishChanges()
        checkWinState()
        persistSave()
    }

    func dismissWinScreen() {
        showWinScreen = false
    }

    /// Pause elapsed time (app background / inactive) and persist progress.
    func pauseTimer() {
        timerService.pause()
        syncElapsedToSession()
        persistSave()
    }

    /// Resume after returning to foreground (no-op if completed).
    func resumeTimer() {
        guard !session.completed else { return }
        guard session.elapsedSeconds > 0 || !session.undoStack.isEmpty || session.cells.contains(where: { $0.state != .empty }) else {
            return
        }
        timerService.resume()
        startTickingIfNeeded()
    }

    /// Explicit save (e.g. app background).
    func persistSave() {
        syncElapsedToSession()
        saveStore.save(session.makeSaveGame())
    }

    private func restoreIfNeeded() {
        guard let save = saveStore.load(puzzleId: session.puzzle.id) else { return }
        do {
            try session.restore(from: save)
            timerService.restore(elapsedSeconds: save.elapsedSeconds, completed: save.completed)
            if session.completed {
                showWinScreen = true
            }
        } catch {
            saveStore.clear(puzzleId: session.puzzle.id)
            session.reset()
            timerService.reset()
            showWinScreen = false
        }
    }

    private func ensureTimerRunning() {
        guard !session.completed else { return }
        timerService.start()
        startTickingIfNeeded()
    }

    private func startTickingIfNeeded() {
        guard tickTask == nil else { return }
        tickTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard let self, !Task.isCancelled else { return }
                self.timerService.tick()
                self.syncElapsedToSession()
            }
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }

    private func syncElapsedToSession() {
        timerService.tick()
        session.setElapsedSeconds(timerService.elapsedSeconds)
    }

    private func playFeedbackIfNeeded(from previous: CellState, to next: CellState) {
        switch (previous, next) {
        case (.empty, .animal), (.blocked, .animal):
            soundService.play(.place)
            hapticService.play(.place)
        case (.animal, .empty):
            soundService.play(.remove)
        case (.empty, .blocked), (.blocked, .empty):
            hapticService.play(.place)
        default:
            break
        }
    }

    private func checkWinState() {
        if session.validationResult.isComplete {
            timerService.stop()
            syncElapsedToSession()
            stopTicking()
            if !showWinScreen {
                soundService.play(.win)
                hapticService.play(.win)
            }
            showWinScreen = true
            publishChanges()
        }
    }

    private func publishChanges() {
        cells = session.cells
        validationResult = session.validationResult
    }
}

/// Ephemeral mark-drag stroke (P5.7).
private struct MarkDragStroke {
    var paintBlocked: Bool?
    var visited: Set<Position> = []
    var changes: [MarkStrokeChange] = []
}
