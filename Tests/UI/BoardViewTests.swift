import XCTest
@testable import AnimalDoku

final class BoardViewTests: XCTestCase {
    func testParseHexColor() {
        let color = RegionColorMap.parseHex("#A8D8EA")
        XCTAssertNotNil(color)
    }

    func testParseHexColorWithoutHashPrefix() {
        let color = RegionColorMap.parseHex("B8E0D2")
        XCTAssertNotNil(color)
    }

    func testInvalidHexReturnsNil() {
        XCTAssertNil(RegionColorMap.parseHex("not-a-color"))
        XCTAssertNil(RegionColorMap.parseHex("#GGGGGG"))
    }

    func testRegionColorMapUsesAccessibleTokensByRegionId() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let colorMap = RegionColorMap(regions: puzzle.regions)

        XCTAssertEqual(colorMap.color(for: 0), AppColors.regionColor(at: 0))
        XCTAssertEqual(colorMap.color(for: 3), AppColors.regionColor(at: 3))
        // Puzzle JSON pastels must not win over the accessible palette (P8.1).
        XCTAssertNotEqual(
            colorMap.color(for: 0),
            RegionColorMap.parseHex(puzzle.regions[0].color)
        )
    }

    func testRegionColorMapFallsBackForUnknownRegion() {
        let colorMap = RegionColorMap(regions: [])
        XCTAssertEqual(colorMap.color(for: 99), AppColors.regionColor(at: 99))
    }

    func testRegionColorMapHighContrastUsesAccessiblePalette() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let defaultMap = RegionColorMap(regions: puzzle.regions, highContrast: false)
        let contrastMap = RegionColorMap(regions: puzzle.regions, highContrast: true)

        XCTAssertEqual(defaultMap.color(for: 0), AppColors.regionColor(at: 0, highContrast: false))
        XCTAssertEqual(contrastMap.color(for: 0), AppColors.regionColor(at: 0, highContrast: true))
        // Same accessible hues; HC distinction is chrome/borders (P8.1).
        XCTAssertEqual(defaultMap.color(for: 0), contrastMap.color(for: 0))
    }

    func testCellSizeMeetsTouchTargetOnIPhoneSE() {
        let seWidth: CGFloat = 375
        let size = 8
        let padding = BoardLayout.boardPadding(availableWidth: seWidth, size: size)
        let cellSize = BoardLayout.cellSize(availableWidth: seWidth, padding: padding, size: size)

        XCTAssertGreaterThanOrEqual(cellSize, TouchTarget.minimum)
    }

    func testBoardFitsWithinSEWidth() {
        let seWidth: CGFloat = 375
        let size = 8
        let padding = BoardLayout.boardPadding(availableWidth: seWidth, size: size)
        let cellSize = BoardLayout.cellSize(availableWidth: seWidth, padding: padding, size: size)
        let boardWidth = CGFloat(size) * cellSize + CGFloat(size - 1) * AppSpacing.cellGap + padding * 2

        XCTAssertLessThanOrEqual(boardWidth, seWidth)
    }

    /// Logical width for iPhone 16 Pro Max (portrait points).
    func testCellSizeMeetsTouchTargetOnProMax() {
        let proMaxWidth: CGFloat = 430
        let size = 8
        let padding = BoardLayout.boardPadding(availableWidth: proMaxWidth, size: size)
        let cellSize = BoardLayout.cellSize(availableWidth: proMaxWidth, padding: padding, size: size)

        XCTAssertGreaterThanOrEqual(cellSize, TouchTarget.minimum)
    }

    func testBoardFitsWithinProMaxWidth() {
        let proMaxWidth: CGFloat = 430
        let size = 8
        let padding = BoardLayout.boardPadding(availableWidth: proMaxWidth, size: size)
        let cellSize = BoardLayout.cellSize(availableWidth: proMaxWidth, padding: padding, size: size)
        let boardWidth = CGFloat(size) * cellSize + CGFloat(size - 1) * AppSpacing.cellGap + padding * 2

        XCTAssertLessThanOrEqual(boardWidth, proMaxWidth)
    }

    func testViolationDetectionIncludesAllPositions() {
        let positionA = Position(row: 0, col: 1)
        let positionB = Position(row: 0, col: 3)
        let result = ValidationResult(
            isValid: false,
            isComplete: false,
            violations: [RuleViolation(rule: .row, positions: [positionA, positionB])]
        )

        XCTAssertTrue(violates(result, at: positionA))
        XCTAssertTrue(violates(result, at: positionB))
        XCTAssertFalse(violates(result, at: Position(row: 2, col: 2)))
    }

    func testBoardLayoutPositionMapsPointToCell() {
        let size = 4
        let padding: CGFloat = 8
        let cellSize: CGFloat = 44
        let gap = AppSpacing.cellGap
        let boardWidth = padding * 2 + CGFloat(size) * cellSize + CGFloat(size - 1) * gap

        let topLeft = BoardLayout.position(
            at: CGPoint(x: padding + cellSize / 2, y: padding + cellSize / 2),
            boardWidth: boardWidth,
            padding: padding,
            cellSize: cellSize,
            size: size
        )
        XCTAssertEqual(topLeft, Position(row: 0, col: 0))

        let second = BoardLayout.position(
            at: CGPoint(
                x: padding + cellSize + gap + cellSize / 2,
                y: padding + cellSize / 2
            ),
            boardWidth: boardWidth,
            padding: padding,
            cellSize: cellSize,
            size: size
        )
        XCTAssertEqual(second, Position(row: 0, col: 1))
    }

    func testBoardLayoutPositionReturnsNilInGapsAndOutside() {
        let size = 4
        let padding: CGFloat = 8
        let cellSize: CGFloat = 44
        let gap = AppSpacing.cellGap
        let boardWidth = padding * 2 + CGFloat(size) * cellSize + CGFloat(size - 1) * gap

        let inGap = BoardLayout.position(
            at: CGPoint(x: padding + cellSize + gap / 2, y: padding + cellSize / 2),
            boardWidth: boardWidth,
            padding: padding,
            cellSize: cellSize,
            size: size
        )
        XCTAssertNil(inGap)

        let outside = BoardLayout.position(
            at: CGPoint(x: 1, y: 1),
            boardWidth: boardWidth,
            padding: padding,
            cellSize: cellSize,
            size: size
        )
        XCTAssertNil(outside)
    }

    private func violates(_ result: ValidationResult, at position: Position) -> Bool {
        result.violations.contains { $0.positions.contains(position) }
    }
}
