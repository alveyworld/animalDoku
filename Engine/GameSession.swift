import Foundation

/// Abstraction over board validation for testability.
protocol Validating {
    func validate(cells: [Cell], puzzle: Puzzle) -> ValidationResult
}

extension Validator: Validating {}

/// Runtime state for an active puzzle attempt.
///
/// MVP puzzles start with an all-empty board (`initialPlacements` is always `[]`).
/// See [Formal Rules §Pre-filled Givens](AnimalDoku_Formal_Rules_and_Data_Model.md#pre-filled-givens).
final class GameSession {
    let puzzle: Puzzle
    private(set) var cells: [Cell]
    private(set) var undoStack: [GameAction] = []
    private(set) var redoStack: [GameAction] = []
    private(set) var hintsUsed: Int = 0
    private(set) var elapsedSeconds: Int = 0
    private(set) var validationResult: ValidationResult

    var completed: Bool { validationResult.isComplete }
    var hintsRemaining: Int { HintService.maxHints - hintsUsed }

    private let validator: Validating
    private let hintService: HintService

    init(puzzle: Puzzle, validator: Validating = Validator(), hintService: HintService = HintService()) {
        self.puzzle = puzzle
        self.validator = validator
        self.hintService = hintService
        self.cells = Self.makeEmptyCells(for: puzzle)
        self.validationResult = validator.validate(cells: cells, puzzle: puzzle)
    }

    /// Syncs tracked play time from `TimerService` into session state (P4.6).
    func setElapsedSeconds(_ seconds: Int) {
        elapsedSeconds = max(0, seconds)
    }

    /// Snapshot for persistence (P4.7). Undo/redo stacks are intentionally omitted.
    func makeSaveGame(mistakes: Int = 0) -> SaveGame {
        SaveGame(
            puzzleId: puzzle.id,
            elapsedSeconds: elapsedSeconds,
            cells: cells,
            hintsUsed: hintsUsed,
            mistakes: mistakes,
            completed: completed
        )
    }

    /// Restores board counters from a save. Clears undo/redo. Re-validates.
    func restore(from save: SaveGame) throws {
        guard save.puzzleId == puzzle.id else {
            throw SaveGameRestoreError.puzzleIdMismatch
        }
        guard save.cells.count == puzzle.size * puzzle.size else {
            throw SaveGameRestoreError.invalidCellCount
        }

        let expected = Self.makeEmptyCells(for: puzzle)
        for (index, cell) in save.cells.enumerated() {
            let expectedCell = expected[index]
            guard cell.row == expectedCell.row,
                  cell.col == expectedCell.col,
                  cell.regionId == expectedCell.regionId else {
                throw SaveGameRestoreError.invalidCellLayout
            }
        }

        cells = save.cells
        hintsUsed = max(0, save.hintsUsed)
        elapsedSeconds = max(0, save.elapsedSeconds)
        undoStack.removeAll()
        redoStack.removeAll()
        revalidate()
    }

    func cell(at position: Position) -> Cell {
        cells[index(for: position)]
    }

    // MARK: - Player actions (P6.5 unified tap)

    // Interaction Model — Formal Rules §Interaction Model (v1.1):
    // | Gesture     | Empty        | Blocked           | Animal         |
    // | Single tap  | Mark X       | Clear X           | No effect      |
    // | Double tap  | Place animal | Clear + place     | Remove animal  |

    /// Single tap — toggle blocked mark. No effect on animal cells.
    func toggleMark(at position: Position) {
        guard !completed else { return }

        switch cell(at: position).state {
        case .empty:
            apply(.toggleBlocked(at: position, previous: .empty))
        case .blocked:
            apply(.toggleBlocked(at: position, previous: .blocked))
        case .animal:
            break
        }
    }

    /// Double tap — place animal (clearing a mark if needed) or remove an animal.
    func placeOrRemove(at position: Position) {
        guard !completed else { return }

        switch cell(at: position).state {
        case .empty:
            apply(.place(at: position, previous: .empty))
        case .blocked:
            apply(.place(at: position, previous: .blocked))
        case .animal:
            apply(.remove(at: position, previous: .animal))
        }
    }

    // MARK: - Mark drag stroke (P5.7)

    /// Paints or clears a mark without pushing undo. Returns previous state if changed.
    func paintMark(at position: Position, paintBlocked: Bool) -> CellState? {
        guard !completed else { return nil }

        let idx = index(for: position)
        let current = cells[idx].state

        if paintBlocked {
            guard current == .empty else { return nil }
            cells[idx].state = .blocked
            revalidate()
            return .empty
        } else {
            guard current == .blocked else { return nil }
            cells[idx].state = .empty
            revalidate()
            return .blocked
        }
    }

    /// Records a completed drag stroke as a single undo entry. Board cells are already painted.
    func commitMarkStroke(_ changes: [MarkStrokeChange]) {
        guard !completed, !changes.isEmpty else { return }
        undoStack.append(.markStroke(changes: changes))
        redoStack.removeAll()
    }

    /// Applies a forward action: mutates the board, records history, and revalidates.
    /// Shared with redo (P3.4); inverse used by undo (P3.3).
    func apply(_ action: GameAction) {
        performForward(action, clearRedoStack: true)
    }

    // MARK: - Undo (P3.3)

    /// Reversal semantics: place/remove/toggleBlocked restore `previousState`; hint restores
    /// `previousState` and decrements `hintsUsed`.
    var canUndo: Bool { !undoStack.isEmpty }

    func undo() {
        guard let action = undoStack.popLast() else { return }
        applyInverse(of: action)
        redoStack.append(action)
        revalidate()
    }

    // MARK: - Redo (P3.4)

    /// Reapplies the last undone action. Pops redo first so `performForward` does not wipe
    /// remaining redo entries (which a full `apply(_:)` would clear).
    var canRedo: Bool { !redoStack.isEmpty }

    func redo() {
        guard let action = redoStack.popLast() else { return }
        performForward(action, clearRedoStack: false)
    }

    // MARK: - Reset (P3.5)

    /// Restores the initial empty board and clears session progress. Does not change `puzzle`
    /// or app-level settings (theme, sound). See Formal Rules §Undo / Redo / Reset.
    func reset() {
        cells = Self.makeEmptyCells(for: puzzle)
        undoStack.removeAll()
        redoStack.removeAll()
        hintsUsed = 0
        elapsedSeconds = 0
        revalidate()
    }

    // MARK: - Hints (P3.6)

    func canHint(selected: Position? = nil) -> Bool {
        hintService.canHint(
            hintsUsed: hintsUsed,
            completed: completed,
            board: cells,
            solution: puzzle.solution,
            size: puzzle.size,
            selected: selected
        )
    }

    @discardableResult
    func requestHint(selected: Position? = nil) -> Bool {
        guard canHint(selected: selected),
              let target = hintService.targetPosition(
                board: cells,
                solution: puzzle.solution,
                size: puzzle.size,
                selected: selected
              ) else {
            return false
        }

        apply(.hint(at: target, previous: .empty))
        return true
    }

    private func performForward(_ action: GameAction, clearRedoStack: Bool) {
        switch action {
        case .place(let at, _):
            cells[index(for: at)].state = .animal
        case .remove(let at, _):
            cells[index(for: at)].state = .empty
        case .toggleBlocked(let at, let previous):
            cells[index(for: at)].state = previous == .empty ? .blocked : .empty
        case .hint(let at, _):
            cells[index(for: at)].state = .animal
            hintsUsed += 1
        case .markStroke(let changes):
            for change in changes {
                cells[index(for: change.at)].state =
                    change.previous == .empty ? .blocked : .empty
            }
        }

        undoStack.append(action)
        if clearRedoStack {
            redoStack.removeAll()
        }
        revalidate()
    }

    private func applyInverse(of action: GameAction) {
        switch action {
        case .place, .remove, .toggleBlocked, .hint:
            cells[index(for: action.position)].state = action.previousState
            if action.isHint {
                hintsUsed -= 1
            }
        case .markStroke(let changes):
            for change in changes.reversed() {
                cells[index(for: change.at)].state = change.previous
            }
        }
    }

    private func revalidate() {
        validationResult = validator.validate(cells: cells, puzzle: puzzle)
    }

    private func index(for position: Position) -> Int {
        position.row * puzzle.size + position.col
    }

    private static func makeEmptyCells(for puzzle: Puzzle) -> [Cell] {
        let regionLookup = regionIdLookup(for: puzzle)
        var cells: [Cell] = []
        cells.reserveCapacity(puzzle.size * puzzle.size)

        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                let position = Position(row: row, col: col)
                let regionId = regionLookup[position] ?? 0
                cells.append(
                    Cell(row: row, col: col, regionId: regionId, state: .empty)
                )
            }
        }

        return cells
    }

    private static func regionIdLookup(for puzzle: Puzzle) -> [Position: Int] {
        var lookup: [Position: Int] = [:]
        for region in puzzle.regions {
            for position in region.cells {
                lookup[position] = region.id
            }
        }
        return lookup
    }
}
