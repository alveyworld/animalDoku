import XCTest

final class AnimalDokuUITests: XCTestCase {
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestPuzzle", "puzzle-valid-4x4"]
        app.launch()

        XCTAssertTrue(app.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["gameView"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["cell_0_0"].waitForExistence(timeout: 5))
    }
}
