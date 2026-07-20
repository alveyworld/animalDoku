import XCTest
@testable import AnimalDoku

/// InputModeToggle was removed in P6.5 (unified tap: mark on single, place on double).
final class InputModeToggleTests: XCTestCase {
    func testInputModeToggleRemovedInP65() throws {
        throw XCTSkip("InputModeToggle removed in P6.5 — Place/Mark mode no longer exists")
    }
}
