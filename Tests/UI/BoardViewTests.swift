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

    func testRegionColorMapUsesPuzzleHexColors() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let colorMap = RegionColorMap(regions: puzzle.regions)

        XCTAssertNotNil(colorMap.color(for: 0))
        XCTAssertNotNil(colorMap.color(for: 3))
    }

    func testRegionColorMapFallsBackForUnknownRegion() {
        let colorMap = RegionColorMap(regions: [])
        XCTAssertNotNil(colorMap.color(for: 99))
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

    private func violates(_ result: ValidationResult, at position: Position) -> Bool {
        result.violations.contains { $0.positions.contains(position) }
    }
}
