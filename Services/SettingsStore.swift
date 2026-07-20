import Foundation
import Observation

/// App-wide player preferences persisted in `UserDefaults`.
///
/// Preferences are cosmetic / UX only — they do not affect puzzle logic (P4.3).
@Observable
final class SettingsStore {
    enum Keys {
        static let selectedThemeId = "settings.selectedThemeId"
        static let soundEnabled = "settings.soundEnabled"
        static let highContrastEnabled = "settings.highContrastEnabled"
        static let tutorialCompleted = "settings.tutorialCompleted"
        static let hapticsEnabled = "settings.hapticsEnabled"
    }

    private let defaults: UserDefaults

    var selectedThemeId: String {
        didSet {
            let normalized = ThemeCatalog.theme(id: selectedThemeId).id
            if normalized != selectedThemeId {
                selectedThemeId = normalized
            }
            defaults.set(selectedThemeId, forKey: Keys.selectedThemeId)
        }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    var highContrastEnabled: Bool {
        didSet { defaults.set(highContrastEnabled, forKey: Keys.highContrastEnabled) }
    }

    /// Set when the player finishes or skips the first-launch tutorial (P5.5).
    var tutorialCompleted: Bool {
        didSet { defaults.set(tutorialCompleted, forKey: Keys.tutorialCompleted) }
    }

    /// Subtle place/win haptics (P5.6). Independent of sound.
    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let storedThemeId = defaults.string(forKey: Keys.selectedThemeId) {
            selectedThemeId = ThemeCatalog.theme(id: storedThemeId).id
        } else {
            selectedThemeId = ThemeCatalog.defaultThemeID
        }

        if defaults.object(forKey: Keys.soundEnabled) != nil {
            soundEnabled = defaults.bool(forKey: Keys.soundEnabled)
        } else {
            soundEnabled = true
        }

        if defaults.object(forKey: Keys.highContrastEnabled) != nil {
            highContrastEnabled = defaults.bool(forKey: Keys.highContrastEnabled)
        } else {
            highContrastEnabled = false
        }

        if defaults.object(forKey: Keys.tutorialCompleted) != nil {
            tutorialCompleted = defaults.bool(forKey: Keys.tutorialCompleted)
        } else {
            tutorialCompleted = false
        }

        if defaults.object(forKey: Keys.hapticsEnabled) != nil {
            hapticsEnabled = defaults.bool(forKey: Keys.hapticsEnabled)
        } else {
            hapticsEnabled = true
        }
    }

    var selectedTheme: Theme {
        ThemeCatalog.theme(id: selectedThemeId)
    }

    func completeTutorial() {
        tutorialCompleted = true
    }
}
