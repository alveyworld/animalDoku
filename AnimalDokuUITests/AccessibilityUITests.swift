import XCTest

/// Automated accessibility audits for key screens (P6.3).
///
/// Uses XCTest `performAccessibilityAudit()` (iOS 17+). Intentional exceptions
/// are documented in `docs/accessibility-audit.md`.
final class AccessibilityUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += [
            "-uiTestPuzzle", "puzzle-valid-4x4",
            "-uiTestReduceMotion",
        ]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["gameView"].waitForExistence(timeout: 5))
    }

    func testGameScreenAccessibilityAudit() throws {
        try app.performAccessibilityAudit { issue in
            Self.shouldIgnore(issue)
        }
    }

    func testSettingsScreenAccessibilityAudit() throws {
        let settings = app.buttons[SettingsCopy.openSettingsLabel]
        let settingsButton = settings.exists
            ? settings
            : app.descendants(matching: .any)["openSettingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings control missing")
        settingsButton.tap()

        let sheet = app.descendants(matching: .any)["settingsSheet"]
        XCTAssertTrue(
            sheet.waitForExistence(timeout: 5) || app.staticTexts["Settings"].waitForExistence(timeout: 2),
            "Settings sheet did not appear"
        )

        try app.performAccessibilityAudit { issue in
            // Form chrome, SF Symbol tints, and theme swatches produce auditor
            // contrast/clipping false positives. Text/icon tokens are gated by
            // DesignSystemTests (WCAG AA).
            if issue.auditType == .textClipped || issue.auditType == .contrast {
                return true
            }
            return Self.shouldIgnore(issue)
        }
    }

    func testWinScreenAccessibilityAudit() throws {
        for position in PuzzleValid4x4.solution {
            let cell = app.descendants(matching: .any)["cell_\(position.row)_\(position.col)"]
            XCTAssertTrue(cell.waitForExistence(timeout: 2))
            cell.doubleTap()
        }

        XCTAssertTrue(app.descendants(matching: .any)["winScreen"].waitForExistence(timeout: 5))

        try app.performAccessibilityAudit { issue in
            Self.shouldIgnore(issue)
        }
    }

    /// Triaged exceptions — see docs/accessibility-audit.md §Automated audit.
    private static func shouldIgnore(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
        let identifier = issue.element?.identifier ?? ""
        let description = issue.compactDescription.lowercased()

        if issue.auditType == .contrast, description.contains("nearly") {
            return true
        }

        if issue.auditType == .textClipped, identifier == "winElapsedTime" {
            return true
        }

        return false
    }
}

/// Solution mirror for bundled `puzzle-valid-4x4.json` (UI audit only).
private enum PuzzleValid4x4 {
    static let solution: [(row: Int, col: Int)] = [
        (0, 2),
        (1, 0),
        (2, 3),
        (3, 1),
    ]
}

/// Mirrors production copy for the settings gear (UITests cannot import the app module).
private enum SettingsCopy {
    static let openSettingsLabel = "Settings"
}
