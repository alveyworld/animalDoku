import XCTest

/// End-to-end play path: launch → place solution → win → play again (P6.2).
final class GameplayUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += [
            "-uiTestPuzzle", Puzzle001.puzzleName,
            "-uiTestReduceMotion",
        ]
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["gameView"].waitForExistence(timeout: 5))
        XCTAssertTrue(cell(row: 0, col: 0).waitForExistence(timeout: 5))
    }

    func testPlayPuzzle001ToWinUndoAndPlayAgain() {
        let first = Puzzle001.solution[0]

        // Secondary path (AC-3): place then undo.
        doubleTapCell(row: first.row, col: first.col)
        assertCellLabel(row: first.row, col: first.col, contains: "animal")

        let undo = app.descendants(matching: .any)["toolbarUndo"]
        XCTAssertTrue(undo.waitForExistence(timeout: 2))
        XCTAssertTrue(undo.isEnabled)
        undo.tap()
        assertCellLabel(row: first.row, col: first.col, contains: "empty")

        // Happy path (AC-1): place full solution via double-tap (P6.5).
        for position in Puzzle001.solution {
            doubleTapCell(row: position.row, col: position.col)
        }

        let winScreen = app.descendants(matching: .any)["winScreen"]
        XCTAssertTrue(winScreen.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Puzzle Complete!"].waitForExistence(timeout: 2))

        // Board locked while win overlay is up (AC-2): toolbar actions disabled.
        XCTAssertFalse(undo.isEnabled)

        // Play Again resets (AC-4).
        let playAgain = app.descendants(matching: .any)["playAgainButton"]
        XCTAssertTrue(playAgain.waitForExistence(timeout: 2))
        playAgain.tap()

        XCTAssertFalse(winScreen.waitForExistence(timeout: 3))
        assertCellLabel(row: first.row, col: first.col, contains: "empty")
        for position in Puzzle001.solution {
            assertCellLabel(row: position.row, col: position.col, contains: "empty")
        }
    }

    // MARK: - Helpers

    private func cell(row: Int, col: Int) -> XCUIElement {
        app.descendants(matching: .any)[Puzzle001.cellId(row: row, col: col)]
    }

    private func doubleTapCell(row: Int, col: Int) {
        let element = cell(row: row, col: col)
        XCTAssertTrue(element.waitForExistence(timeout: 2), "Missing \(Puzzle001.cellId(row: row, col: col))")
        element.doubleTap()
    }

    private func assertCellLabel(row: Int, col: Int, contains token: String) {
        let element = cell(row: row, col: col)
        XCTAssertTrue(element.waitForExistence(timeout: 2))
        // Label is on the cell button; identifier may be on a parent — resolve via query.
        let label = element.label
        let resolved = label.isEmpty
            ? element.buttons.firstMatch.label
            : label
        XCTAssertTrue(
            resolved.localizedCaseInsensitiveContains(token),
            "Expected cell (\(row),\(col)) label to contain '\(token)', got '\(resolved)'"
        )
    }
}
