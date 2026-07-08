import Foundation

/// Selects hint targets and validates hint preconditions.
/// See [Formal Rules §Hint System](AnimalDoku_Formal_Rules_and_Data_Model.md#hint-system).
struct HintService {
    static let maxHints = 3

    /// Returns the cell to reveal, or `nil` when no valid hint target exists.
    func targetPosition(
        board: [Cell],
        solution: [Position],
        size: Int,
        selected: Position?
    ) -> Position? {
        let solutionPositions = Set(solution)

        if let selected {
            guard solutionPositions.contains(selected) else { return nil }
            guard cellState(at: selected, board: board, size: size) == .empty else { return nil }
            return selected
        }

        for row in 0..<size {
            for col in 0..<size {
                let position = Position(row: row, col: col)
                guard solutionPositions.contains(position) else { continue }
                if cellState(at: position, board: board, size: size) == .empty {
                    return position
                }
            }
        }

        return nil
    }

    func canHint(
        hintsUsed: Int,
        completed: Bool,
        board: [Cell],
        solution: [Position],
        size: Int,
        selected: Position?
    ) -> Bool {
        guard hintsUsed < Self.maxHints, !completed else { return false }
        return targetPosition(
            board: board,
            solution: solution,
            size: size,
            selected: selected
        ) != nil
    }

    private func cellState(at position: Position, board: [Cell], size: Int) -> CellState {
        board[position.row * size + position.col].state
    }
}
