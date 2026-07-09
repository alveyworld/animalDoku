import SwiftUI

/// Responsive N×N puzzle grid composed of `CellView` instances.
///
/// Sizing formula (portrait width `W`, grid `size`, gap `g`, padding `p`):
/// `cellSize = (W - 2p - (size - 1) * g) / size`
/// Padding tightens on narrow screens so each cell can stay ≥ 44 pt (GDD accessibility).
///
/// Region colorblind patterns (P3.10) render between the region fill and `CellView`.
struct BoardView: View {
    let puzzle: Puzzle
    let cells: [Cell]
    let validationResult: ValidationResult
    var selectedPosition: Position? = nil
    var isBoardLocked: Bool = false
    var animalIcon: Image = ThemeAsset.image(for: "frogs")
    var onCellTap: (Position) -> Void = { _ in }

    private var regionColors: RegionColorMap {
        RegionColorMap(regions: puzzle.regions)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = puzzle.size
            let padding = BoardLayout.boardPadding(availableWidth: geometry.size.width, size: size)
            let cellSize = BoardLayout.cellSize(
                availableWidth: geometry.size.width,
                padding: padding,
                size: size
            )
            let columns = Array(
                repeating: GridItem(.fixed(cellSize), spacing: AppSpacing.cellGap),
                count: size
            )

            LazyVGrid(columns: columns, spacing: AppSpacing.cellGap) {
                ForEach(0..<cells.count, id: \.self) { index in
                    boardCell(cells[index], cellSize: cellSize)
                }
            }
            .padding(padding)
            .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
            .opacity(isBoardLocked ? 0.85 : 1)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Puzzle board")
        .accessibilityIdentifier("gameBoard")
    }

    @ViewBuilder
    private func boardCell(_ cell: Cell, cellSize: CGFloat) -> some View {
        let position = Position(row: cell.row, col: cell.col)

        CellView(
            row: cell.row,
            col: cell.col,
            regionId: cell.regionId,
            state: cell.state,
            isSelected: selectedPosition == position,
            isViolating: isViolating(at: position),
            animalIcon: animalIcon,
            onTap: { onCellTap(position) }
        )
        .frame(width: cellSize, height: cellSize)
        .background {
            ZStack {
                regionColors.color(for: cell.regionId)
                RegionPattern(regionId: cell.regionId)
            }
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                .strokeBorder(AppColors.border.opacity(0.45), lineWidth: AppSpacing.borderWeight)
                .allowsHitTesting(false)
        )
        .accessibilityIdentifier("cell_\(cell.row)_\(cell.col)")
    }

    private func isViolating(at position: Position) -> Bool {
        validationResult.violations.contains { $0.positions.contains(position) }
    }
}

// MARK: - Layout

enum BoardLayout {
    static func boardPadding(availableWidth: CGFloat, size: Int) -> CGFloat {
        let minimumBoardWidth = minimumWidth(for: size)
        let centeredPadding = (availableWidth - minimumBoardWidth) / 2
        return min(AppSpacing.boardPadding, max(0, centeredPadding))
    }

    static func cellSize(availableWidth: CGFloat, padding: CGFloat, size: Int) -> CGFloat {
        let totalGaps = CGFloat(size - 1) * AppSpacing.cellGap
        let fitSize = (availableWidth - (padding * 2) - totalGaps) / CGFloat(size)
        return max(fitSize, TouchTarget.minimum)
    }

    static func minimumWidth(for size: Int) -> CGFloat {
        CGFloat(size) * TouchTarget.minimum + CGFloat(size - 1) * AppSpacing.cellGap
    }
}

// MARK: - Previews

#if DEBUG
private enum BoardPreviewData {
    static let puzzle = Puzzle(
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

    static var emptyCells: [Cell] {
        var cells: [Cell] = []
        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                let position = Position(row: row, col: col)
                cells.append(
                    Cell(
                        row: row,
                        col: col,
                        regionId: regionId(for: position),
                        state: .empty
                    )
                )
            }
        }
        return cells
    }

    static var mixedCells: [Cell] {
        emptyCells.map { cell in
            var updated = cell
            if cell.row == 0 && cell.col == 1 {
                updated.state = .animal
            } else if cell.row == 1 && cell.col == 3 {
                updated.state = .animal
            } else if cell.row == 2 && cell.col == 0 {
                updated.state = .blocked
            }
            return updated
        }
    }

    static var rowViolation: ValidationResult {
        ValidationResult(
            isValid: false,
            isComplete: false,
            violations: [
                RuleViolation(
                    rule: .row,
                    positions: [Position(row: 0, col: 1), Position(row: 0, col: 3)]
                ),
            ]
        )
    }

    private static func regionId(for position: Position) -> Int {
        puzzle.regions.first { region in
            region.cells.contains(position)
        }?.id ?? 0
    }
}

#Preview("4×4 Board") {
    BoardView(
        puzzle: BoardPreviewData.puzzle,
        cells: BoardPreviewData.mixedCells,
        validationResult: ValidationResult(isValid: true, isComplete: false, violations: []),
        selectedPosition: Position(row: 2, col: 0)
    )
    .padding(AppSpacing.md)
    .background(AppColors.background)
}

#Preview("Row Violation") {
    BoardView(
        puzzle: BoardPreviewData.puzzle,
        cells: BoardPreviewData.mixedCells,
        validationResult: BoardPreviewData.rowViolation,
        selectedPosition: Position(row: 0, col: 1)
    )
    .padding(AppSpacing.md)
    .background(AppColors.background)
}
#endif
