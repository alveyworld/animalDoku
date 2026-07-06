import Foundation

/// Place vs. mark (blocked) input mode. See [Formal Rules §Interaction Model](AnimalDoku_Formal_Rules_and_Data_Model.md#interaction-model).
enum InputMode: Equatable {
    case place
    case mark
}

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
    static let maxHints = 3

    let puzzle: Puzzle
    private(set) var cells: [Cell]
    private(set) var undoStack: [GameAction] = []
    private(set) var redoStack: [GameAction] = []
    private(set) var hintsUsed: Int = 0
    private(set) var elapsedSeconds: Int = 0
    var inputMode: InputMode = .place
    private(set) var validationResult: ValidationResult

    var completed: Bool { validationResult.isComplete }

    private let validator: Validating

    init(puzzle: Puzzle, validator: Validating = Validator()) {
        self.puzzle = puzzle
        self.validator = validator
        self.cells = Self.makeEmptyCells(for: puzzle)
        self.validationResult = validator.validate(cells: cells, puzzle: puzzle)
    }

    func cell(at position: Position) -> Cell {
        cells[index(for: position)]
    }

    // MARK: - Player actions (P3.2)

    // Interaction Model — Formal Rules §Interaction Model:
    // | Mode  | Tap empty   | Tap blocked | Tap animal    |
    // | Place | Place animal| No effect   | Remove animal |
    // | Mark  | Toggle X    | Clear X     | No effect     |

    /// Routes a cell tap based on `inputMode` and the cell's current state.
    func tap(at position: Position) {
        guard !completed else { return }

        let currentState = cell(at: position).state

        switch inputMode {
        case .place:
            switch currentState {
            case .empty:
                apply(.place(at: position, previous: .empty))
            case .animal:
                apply(.remove(at: position, previous: .animal))
            case .blocked:
                break
            }
        case .mark:
            switch currentState {
            case .empty:
                apply(.toggleBlocked(at: position, previous: .empty))
            case .blocked:
                apply(.toggleBlocked(at: position, previous: .blocked))
            case .animal:
                break
            }
        }
    }

    /// Applies a forward action: mutates the board, records history, and revalidates.
    /// Shared with redo (P3.4); inverse used by undo (P3.3).
    func apply(_ action: GameAction) {
        let idx = index(for: action.position)

        switch action {
        case .place:
            cells[idx].state = .animal
        case .remove:
            cells[idx].state = .empty
        case .toggleBlocked(_, let previous):
            cells[idx].state = previous == .empty ? .blocked : .empty
        case .hint:
            cells[idx].state = .animal
        }

        undoStack.append(action)
        redoStack.removeAll()
        revalidate()
    }

    /// Reverses the last action and moves it to the redo stack. Full spec: P3.3.
    func undo() {
        guard let action = undoStack.popLast() else { return }
        cells[index(for: action.position)].state = action.previousState
        redoStack.append(action)
        revalidate()
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
