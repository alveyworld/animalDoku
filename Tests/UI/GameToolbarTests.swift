import XCTest
@testable import AnimalDoku

final class GameToolbarTests: XCTestCase {
    func testHintLabelIncludesRemainingCount() {
        XCTAssertEqual(
            GameToolbarAccessibility.hintLabel(remaining: 2),
            "Hint, 2 remaining"
        )
    }

    func testHintLabelWhenNoHintsRemaining() {
        XCTAssertEqual(GameToolbarAccessibility.hintLabel(remaining: 0), "Hint")
    }

    func testHintHintWhenHintsAvailable() {
        XCTAssertEqual(
            GameToolbarAccessibility.hintHint(remaining: 1),
            "Reveals one correct cell"
        )
    }

    func testHintHintWhenNoHintsRemaining() {
        XCTAssertEqual(
            GameToolbarAccessibility.hintHint(remaining: 0),
            "No hints remaining"
        )
    }

    func testUndoAccessibilityLabels() {
        XCTAssertEqual(GameToolbarAccessibility.undoLabel, "Undo")
        XCTAssertEqual(GameToolbarAccessibility.undoHint, "Reverts the last move")
    }

    func testResetAccessibilityLabels() {
        XCTAssertEqual(GameToolbarAccessibility.resetLabel, "Reset puzzle")
        XCTAssertEqual(GameToolbarAccessibility.resetHint, "Clears the board and starts over")
    }
}
