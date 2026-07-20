import Foundation

/// A reversible player move for undo/redo history.
/// See [Formal Rules §Player Actions](AnimalDoku_Formal_Rules_and_Data_Model.md#player-actions).
enum GameAction: Equatable {
    case place(at: Position, previous: CellState)
    case remove(at: Position, previous: CellState)
    case toggleBlocked(at: Position, previous: CellState)
    case hint(at: Position, previous: CellState)
    /// One drag stroke in Mark mode (P5.7) — undoes as a single step.
    case markStroke(changes: [MarkStrokeChange])

    var position: Position {
        switch self {
        case .place(let at, _), .remove(let at, _), .toggleBlocked(let at, _), .hint(let at, _):
            at
        case .markStroke(let changes):
            changes.first?.at ?? Position(row: 0, col: 0)
        }
    }

    /// Cell state before this action was applied. Restoring this value undoes the move.
    /// For `markStroke`, returns the first change's previous state (use `markStrokeChanges` for full undo).
    var previousState: CellState {
        switch self {
        case .place(_, let previous), .remove(_, let previous),
             .toggleBlocked(_, let previous), .hint(_, let previous):
            previous
        case .markStroke(let changes):
            changes.first?.previous ?? .empty
        }
    }

    var isHint: Bool {
        if case .hint = self { return true }
        return false
    }

    var markStrokeChanges: [MarkStrokeChange] {
        if case .markStroke(let changes) = self { return changes }
        return []
    }
}

/// One cell mutation inside a mark-drag stroke.
struct MarkStrokeChange: Equatable {
    let at: Position
    let previous: CellState
}
