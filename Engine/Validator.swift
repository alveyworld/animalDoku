import Foundation

/// Validates board state against Animal Doku rules.
/// Rules 1–3 (uniqueness) in P2.4; Rule 4 (adjacency) in P2.5; Rule 5 (completion) in P2.6.
/// See [Formal Rules §Validation](AnimalDoku_Formal_Rules_and_Data_Model.md#validation).
struct Validator {
    private static let neighborOffsets: [(dr: Int, dc: Int)] = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1),           (0, 1),
        (1, -1),  (1, 0),  (1, 1),
    ]

    private static let ruleOrder: [RuleType: Int] = [
        .row: 0,
        .column: 1,
        .region: 2,
        .adjacency: 3,
    ]

    /// Runs Rules 1–4 and computes completion (Rule 5). Does not mutate `cells`.
    func validate(cells: [Cell], puzzle: Puzzle) -> ValidationResult {
        let violations = Self.sortedViolations(
            uniquenessViolations(cells: cells, size: puzzle.size)
                + adjacencyViolations(cells: cells, size: puzzle.size)
        )
        let isValid = violations.isEmpty
        let isComplete = isValid
            && self.isComplete(cells: cells, size: puzzle.size, regionCount: puzzle.size)

        return ValidationResult(
            isValid: isValid,
            isComplete: isComplete,
            violations: violations
        )
    }

    /// Rules 1–3: at most one animal per row, column, and region.
    /// Returns one violation per conflicting line, listing all animals involved.
    func uniquenessViolations(cells: [Cell], size: Int) -> [RuleViolation] {
        let animals = cells.filter { $0.state == .animal }
        var violations: [RuleViolation] = []

        violations.append(contentsOf: lineViolations(animals: animals, rule: .row, key: \.row))
        violations.append(contentsOf: lineViolations(animals: animals, rule: .column, key: \.col))
        violations.append(contentsOf: lineViolations(animals: animals, rule: .region, key: \.regionId))

        return violations
    }

    /// Rule 4: animals must not touch in any of eight directions.
    /// See [Formal Rules §Rule 4](AnimalDoku_Formal_Rules_and_Data_Model.md#rule-4--animals-cannot-touch).
    func adjacencyViolations(cells: [Cell], size: Int) -> [RuleViolation] {
        let animals = cells
            .filter { $0.state == .animal }
            .sorted { $0.row == $1.row ? $0.col < $1.col : $0.row < $1.row }

        let animalKeys = Set(animals.map { positionKey(row: $0.row, col: $0.col) })
        var violations: [RuleViolation] = []

        for cell in animals {
            let position = Position(row: cell.row, col: cell.col)

            for offset in Self.neighborOffsets {
                let neighborRow = cell.row + offset.dr
                let neighborCol = cell.col + offset.dc

                guard (0..<size).contains(neighborRow),
                      (0..<size).contains(neighborCol) else {
                    continue
                }

                guard animalKeys.contains(positionKey(row: neighborRow, col: neighborCol)) else {
                    continue
                }

                let neighbor = Position(row: neighborRow, col: neighborCol)
                guard isRowMajorAfter(neighbor, than: position) else {
                    continue
                }

                violations.append(
                    RuleViolation(rule: .adjacency, positions: [position, neighbor])
                )
            }
        }

        return violations
    }

    /// Rule 5: puzzle is complete when all rules pass and exactly `size` animals are placed.
    /// See [Formal Rules §Rule 5](AnimalDoku_Formal_Rules_and_Data_Model.md#rule-5--puzzle-completion).
    func isComplete(cells: [Cell], size: Int, regionCount: Int) -> Bool {
        let animals = cells.filter { $0.state == .animal }
        guard animals.count == size else { return false }
        guard Set(animals.map(\.regionId)) == Set(0..<regionCount) else { return false }
        guard uniquenessViolations(cells: cells, size: size).isEmpty else { return false }
        guard adjacencyViolations(cells: cells, size: size).isEmpty else { return false }
        return true
    }

    private func lineViolations(
        animals: [Cell],
        rule: RuleType,
        key: KeyPath<Cell, Int>
    ) -> [RuleViolation] {
        var buckets: [Int: [Position]] = [:]

        for cell in animals {
            let position = Position(row: cell.row, col: cell.col)
            buckets[cell[keyPath: key], default: []].append(position)
        }

        return buckets
            .filter { $0.value.count > 1 }
            .sorted { $0.key < $1.key }
            .map { _, positions in
                RuleViolation(rule: rule, positions: Self.sortedRowMajor(positions))
            }
    }

    private static func sortedRowMajor(_ positions: [Position]) -> [Position] {
        positions.sorted {
            if $0.row == $1.row {
                return $0.col < $1.col
            }
            return $0.row < $1.row
        }
    }

    private static func sortedViolations(_ violations: [RuleViolation]) -> [RuleViolation] {
        violations.sorted { lhs, rhs in
            let leftOrder = ruleOrder[lhs.rule] ?? 99
            let rightOrder = ruleOrder[rhs.rule] ?? 99
            if leftOrder != rightOrder {
                return leftOrder < rightOrder
            }

            let leftFirst = lhs.positions.first ?? Position(row: 0, col: 0)
            let rightFirst = rhs.positions.first ?? Position(row: 0, col: 0)
            if leftFirst.row != rightFirst.row {
                return leftFirst.row < rightFirst.row
            }
            return leftFirst.col < rightFirst.col
        }
    }

    private func positionKey(row: Int, col: Int) -> String {
        "\(row),\(col)"
    }

    private func isRowMajorAfter(_ lhs: Position, than rhs: Position) -> Bool {
        lhs.row > rhs.row || (lhs.row == rhs.row && lhs.col > rhs.col)
    }
}
