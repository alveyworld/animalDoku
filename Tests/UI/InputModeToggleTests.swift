import XCTest
@testable import AnimalDoku

final class InputModeToggleTests: XCTestCase {
    func testValueLabelForPlaceMode() {
        XCTAssertEqual(
            InputModeToggleAccessibility.valueLabel(for: .place),
            "Place mode"
        )
    }

    func testValueLabelForMarkMode() {
        XCTAssertEqual(
            InputModeToggleAccessibility.valueLabel(for: .mark),
            "Mark mode"
        )
    }

    func testHintDescribesPlaceBehavior() {
        XCTAssertEqual(
            InputModeToggleAccessibility.hint(for: .place),
            "Tap cells to place animals"
        )
    }

    func testHintDescribesMarkBehavior() {
        XCTAssertEqual(
            InputModeToggleAccessibility.hint(for: .mark),
            "Tap cells to mark impossible"
        )
    }

    func testAnnouncementMatchesValueLabel() {
        for mode in [InputMode.place, .mark] {
            XCTAssertEqual(
                InputModeToggleAccessibility.announcement(for: mode),
                InputModeToggleAccessibility.valueLabel(for: mode)
            )
        }
    }
}
