import XCTest
import SwiftUI
@testable import AnimalDoku

final class CellViewTests: XCTestCase {
    func testAccessibilityLabelForEmptyCell() {
        let label = CellViewAccessibility.label(
            row: 0,
            col: 2,
            regionId: 1,
            state: .empty,
            isViolating: false
        )
        XCTAssertEqual(label, "Row 1, Column 3, Region 1, empty")
    }

    func testAccessibilityLabelIncludesViolation() {
        let label = CellViewAccessibility.label(
            row: 3,
            col: 4,
            regionId: 2,
            state: .animal,
            isViolating: true
        )
        XCTAssertEqual(label, "Row 4, Column 5, Region 2, animal, violation")
    }

    func testAccessibilityLabelForBlockedCell() {
        let label = CellViewAccessibility.label(
            row: 5,
            col: 0,
            regionId: 0,
            state: .blocked,
            isViolating: false
        )
        XCTAssertEqual(label, "Row 6, Column 1, Region 0, blocked")
    }

    func testAccessibilityLabelIncludesSelectedAndLocked() {
        let label = CellViewAccessibility.label(
            row: 1,
            col: 1,
            regionId: 0,
            state: .empty,
            isViolating: false,
            isSelected: true,
            isBoardLocked: true
        )
        XCTAssertEqual(label, "Row 2, Column 2, Region 0, empty, selected, locked")
    }

    func testAccessibilityTraitsIncludeSelected() {
        let traits = CellViewAccessibility.traits(isSelected: true, isBoardLocked: false)
        XCTAssertTrue(traits.contains(.isSelected))
        XCTAssertTrue(traits.contains(.isButton))
    }

    func testBlockedMarkUsesWhiteTypographicX() {
        XCTAssertEqual(BlockedMark.glyph, "X")
        XCTAssertEqual(BlockedMark.fontName, "Vaseline Extra")
        XCTAssertEqual(BlockedMark.sizeScale, 1.0, accuracy: 0.001)
    }

    func testBlockedMarkActionNamesUnchanged() {
        XCTAssertEqual(CellViewAccessibility.markActionName(for: .blocked), "Clear mark")
        XCTAssertEqual(CellViewAccessibility.markActionName(for: .empty), "Mark")
        XCTAssertEqual(CellViewAccessibility.placeActionName(for: .blocked), "Place animal")
    }
}
