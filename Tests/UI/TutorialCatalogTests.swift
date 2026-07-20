import XCTest
@testable import AnimalDoku

final class TutorialCatalogTests: XCTestCase {
    func testTutorialHasFiveStepsOrFewer() {
        XCTAssertFalse(TutorialCatalog.steps.isEmpty)
        XCTAssertLessThanOrEqual(TutorialCatalog.steps.count, 5)
    }

    func testTutorialCoversRequiredTopics() {
        let ids = Set(TutorialCatalog.steps.map(\.id))
        XCTAssertTrue(ids.contains("uniqueness"))
        XCTAssertTrue(ids.contains("noTouch"))
        XCTAssertTrue(ids.contains("modes"))
        XCTAssertTrue(ids.contains("win"))
    }

    func testTutorialStepCopyIsNonEmpty() {
        for step in TutorialCatalog.steps {
            XCTAssertFalse(step.title.isEmpty, step.id)
            XCTAssertFalse(step.body.isEmpty, step.id)
            XCTAssertFalse(step.systemImage.isEmpty, step.id)
        }
    }

    func testShouldPresentOnFirstLaunch() {
        let configuration = AppLaunchConfiguration(arguments: [])
        XCTAssertTrue(
            TutorialCatalog.shouldPresent(
                tutorialCompleted: false,
                configuration: configuration
            )
        )
    }

    func testShouldNotPresentAfterCompletion() {
        let configuration = AppLaunchConfiguration(arguments: [])
        XCTAssertFalse(
            TutorialCatalog.shouldPresent(
                tutorialCompleted: true,
                configuration: configuration
            )
        )
    }

    func testShouldNotPresentForUITestPuzzleOverride() {
        let configuration = AppLaunchConfiguration(
            arguments: ["-uiTestPuzzle", "puzzle-valid-4x4"]
        )
        XCTAssertFalse(
            TutorialCatalog.shouldPresent(
                tutorialCompleted: false,
                configuration: configuration
            )
        )
    }

    func testShouldNotPresentWhenFeatureDisabled() {
        let configuration = AppLaunchConfiguration(arguments: [])
        XCTAssertFalse(
            TutorialCatalog.shouldPresent(
                tutorialCompleted: false,
                configuration: configuration,
                enabled: false
            )
        )
    }

    func testAccessibilityCopyIsNonEmpty() {
        XCTAssertFalse(TutorialAccessibility.skipLabel.isEmpty)
        XCTAssertFalse(TutorialAccessibility.nextLabel.isEmpty)
        XCTAssertFalse(TutorialAccessibility.startLabel.isEmpty)
        XCTAssertFalse(TutorialAccessibility.replayLabel.isEmpty)
    }
}
