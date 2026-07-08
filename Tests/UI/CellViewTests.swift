import XCTest
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
}
