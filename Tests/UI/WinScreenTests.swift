import XCTest
@testable import AnimalDoku

final class WinScreenTests: XCTestCase {
    func testTitleMatchesGDD() {
        XCTAssertEqual(WinScreenAccessibility.title, "Puzzle Complete!")
    }

    func testPlayAgainAccessibilityLabel() {
        XCTAssertEqual(WinScreenAccessibility.playAgainLabel, "Play again")
    }
}
