import Foundation

/// A reversible player move for undo/redo history.
/// See [Formal Rules §Player Actions](AnimalDoku_Formal_Rules_and_Data_Model.md#player-actions).
enum GameAction: Equatable {
    case place(at: Position, previous: CellState)
    case remove(at: Position, previous: CellState)
    case toggleBlocked(at: Position, previous: CellState)
    case hint(at: Position, previous: CellState)

    var position: Position {
        switch self {
        case .place(let at, _), .remove(let at, _), .toggleBlocked(let at, _), .hint(let at, _):
            at
        }
    }

    /// Cell state before this action was applied. Restoring this value undoes the move.
    var previousState: CellState {
        switch self {
        case .place(_, let previous), .remove(_, let previous),
             .toggleBlocked(_, let previous), .hint(_, let previous):
            previous
        }
    }

    var isHint: Bool {
        if case .hint = self { return true }
        return false
    }
}
