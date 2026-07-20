import Foundation

/// One page in the first-launch tutorial (P5.5).
struct TutorialStep: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let systemImage: String
}

/// Data-driven tutorial content. Edit steps here without changing `TutorialView` structure.
enum TutorialCatalog {
    /// Feature gate — disable to ship without onboarding.
    static let isEnabled = true

    static let steps: [TutorialStep] = [
        TutorialStep(
            id: "welcome",
            title: String(localized: "tutorial.welcome.title", defaultValue: "Welcome to Animal Doku"),
            body: String(
                localized: "tutorial.welcome.body",
                defaultValue: "A calm logic puzzle. Place animals so each row, column, and colored region has exactly one — and no two animals touch, even diagonally."
            ),
            systemImage: "pawprint.fill"
        ),
        TutorialStep(
            id: "uniqueness",
            title: String(localized: "tutorial.uniqueness.title", defaultValue: "One Per Row, Column & Region"),
            body: String(
                localized: "tutorial.uniqueness.body",
                defaultValue: "Every row needs one animal. Every column needs one. Every colored region needs one. No doubles allowed."
            ),
            systemImage: "square.grid.3x3.fill"
        ),
        TutorialStep(
            id: "noTouch",
            title: String(localized: "tutorial.noTouch.title", defaultValue: "Animals Never Touch"),
            body: String(
                localized: "tutorial.noTouch.body",
                defaultValue: "Animals cannot sit next to each other — including diagonally. Leave a buffer of empty or marked cells."
            ),
            systemImage: "dot.square"
        ),
        TutorialStep(
            id: "modes",
            title: String(localized: "tutorial.modes.title", defaultValue: "Tap & Double-Tap"),
            body: String(
                localized: "tutorial.modes.body",
                defaultValue: "Tap a cell to mark it with an X when you know it’s impossible. Double-tap to place an animal — or double-tap an animal to remove it. Drag across cells to mark several at once."
            ),
            systemImage: "hand.tap.fill"
        ),
        TutorialStep(
            id: "win",
            title: String(localized: "tutorial.win.title", defaultValue: "How to Win"),
            body: String(
                localized: "tutorial.win.body",
                defaultValue: "Fill the board with a valid placement for every animal. When all rules are satisfied, you win. Take your time — under a minute to learn, as long as you like to play."
            ),
            systemImage: "checkmark.seal.fill"
        ),
    ]

    /// Whether onboarding should appear for this launch.
    static func shouldPresent(
        tutorialCompleted: Bool,
        configuration: AppLaunchConfiguration,
        enabled: Bool = isEnabled
    ) -> Bool {
        guard enabled else { return false }
        guard !tutorialCompleted else { return false }
        // UI tests deep-link straight into a puzzle and must not be blocked.
        if configuration.hasUITestPuzzleOverride { return false }
        return true
    }
}
