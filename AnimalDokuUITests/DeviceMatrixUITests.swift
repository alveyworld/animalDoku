import XCTest

/// Layout and playability checks across the device matrix (P6.4).
///
/// Set `DEVICE_MATRIX_OUT` (directory) and optional `DEVICE_MATRIX_SLUG` when running
/// `scripts/run-device-matrix.sh` to write PNG evidence into `docs/device-matrix/`.
final class DeviceMatrixUITests: XCTestCase {
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
    }

    func testBoardIsSquareAndCellsMeetTouchTarget() {
        let board = app.descendants(matching: .any)["gameBoard"]
        XCTAssertTrue(board.waitForExistence(timeout: 5))

        let boardFrame = board.frame
        XCTAssertGreaterThan(boardFrame.width, 0)
        XCTAssertEqual(
            boardFrame.width,
            boardFrame.height,
            accuracy: 2,
            "Board must stay square within safe areas"
        )

        let cell = app.descendants(matching: .any)[Puzzle001.cellId(row: 0, col: 0)]
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        let cellFrame = cell.frame
        XCTAssertGreaterThanOrEqual(
            min(cellFrame.width, cellFrame.height),
            44,
            "Cell tap target must be ≥44×44 pt (got \(cellFrame))"
        )

        saveScreenshot(named: "game")
    }

    func testToolbarSettingsAndWinLayouts() {
        let toolbar = app.descendants(matching: .any)["gameToolbar"]
        XCTAssertTrue(toolbar.waitForExistence(timeout: 2))
        XCTAssertTrue(toolbar.frame.maxY <= app.windows.firstMatch.frame.maxY + 1)

        openSettings()
        let sheet = app.descendants(matching: .any)["settingsSheet"]
        XCTAssertTrue(
            sheet.waitForExistence(timeout: 5) || app.staticTexts["Settings"].waitForExistence(timeout: 2),
            "Settings sheet did not appear"
        )
        saveScreenshot(named: "settings")

        let done = app.descendants(matching: .any)["settingsDoneButton"].firstMatch
        if done.waitForExistence(timeout: 2) {
            done.tap()
        } else {
            app.swipeDown()
        }
        XCTAssertFalse(sheet.waitForExistence(timeout: 2))

        for position in Puzzle001.solution {
            let cell = app.descendants(matching: .any)[Puzzle001.cellId(row: position.row, col: position.col)]
            XCTAssertTrue(cell.waitForExistence(timeout: 2))
            cell.doubleTap()
        }

        let win = app.descendants(matching: .any)["winScreen"]
        XCTAssertTrue(win.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["playAgainButton"].exists)
        saveScreenshot(named: "win")
    }

    func testPortraitLayoutPersistsAfterRotationAttempt() {
        let game = app.descendants(matching: .any)["gameView"].firstMatch
        XCTAssertTrue(game.waitForExistence(timeout: 2))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists)
        let before = window.frame
        XCTAssertGreaterThan(before.height, before.width, "Window should be portrait")

        XCUIDevice.shared.orientation = .landscapeLeft
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))

        let after = window.frame
        XCTAssertGreaterThan(
            after.height,
            after.width,
            "App must remain portrait-locked (GDD); window stayed landscape"
        )

        XCUIDevice.shared.orientation = .portrait
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
    }

    // MARK: - Helpers

    private func openSettings() {
        let byId = app.descendants(matching: .any)["openSettingsButton"]
        if byId.waitForExistence(timeout: 2) {
            byId.tap()
            return
        }
        let byLabel = app.buttons["Settings"]
        XCTAssertTrue(byLabel.waitForExistence(timeout: 2), "Settings control missing")
        byLabel.tap()
    }

    private func saveScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let slug: String = {
            let stamp = URL(fileURLWithPath: "/tmp/animaldoku-device-matrix/current-slug")
            if let data = try? Data(contentsOf: stamp),
               let value = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !value.isEmpty {
                return value
            }
            return ProcessInfo.processInfo.environment["DEVICE_MATRIX_SLUG"]
                ?? "device"
        }()
        let fileName = "\(slug)-\(name).png"

        var directories: [URL] = [
            URL(fileURLWithPath: "/tmp/animaldoku-device-matrix", isDirectory: true),
        ]
        if let custom = ProcessInfo.processInfo.environment["DEVICE_MATRIX_OUT"], !custom.isEmpty {
            directories.insert(URL(fileURLWithPath: custom, isDirectory: true), at: 0)
        }

        for directory in directories {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                let url = directory.appendingPathComponent(fileName)
                try screenshot.pngRepresentation.write(to: url)
                return
            } catch {
                continue
            }
        }
    }
}
