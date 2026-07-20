import SwiftUI

/// Modal settings sheet for theme, sound, and high-contrast preferences (P4.4).
///
/// All values bind to `SettingsStore` — no independent preference state.
struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @State private var showTutorial = false

    var body: some View {
        @Bindable var settings = settings
        let contrast = settings.highContrastEnabled

        NavigationStack {
            Form {
                Section {
                    ThemePicker(
                        selectedThemeId: $settings.selectedThemeId,
                        showsSectionLabel: false
                    )
                    .listRowInsets(EdgeInsets(
                        top: AppSpacing.sm,
                        leading: AppSpacing.md,
                        bottom: AppSpacing.sm,
                        trailing: AppSpacing.md
                    ))
                    .listRowBackground(AppColors.resolvedSurface(highContrast: contrast))
                } header: {
                    Text(SettingsViewAccessibility.themeSection)
                }

                Section {
                    Toggle(isOn: $settings.soundEnabled) {
                        Label {
                            Text(SettingsViewAccessibility.soundLabel)
                        } icon: {
                            Image(systemName: settings.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        }
                    }
                    .tint(AppColors.resolvedAccent(highContrast: contrast))
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(SettingsViewAccessibility.soundLabel)
                    .accessibilityValue(settings.soundEnabled ? "On" : "Off")
                    .accessibilityIdentifier("settingsSoundToggle")

                    Toggle(isOn: $settings.hapticsEnabled) {
                        Label {
                            Text(SettingsViewAccessibility.hapticsLabel)
                        } icon: {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                        }
                    }
                    .tint(AppColors.resolvedAccent(highContrast: contrast))
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(SettingsViewAccessibility.hapticsLabel)
                    .accessibilityValue(settings.hapticsEnabled ? "On" : "Off")
                    .accessibilityIdentifier("settingsHapticsToggle")
                } header: {
                    Text(SettingsViewAccessibility.soundSection)
                }

                Section {
                    Toggle(isOn: $settings.highContrastEnabled) {
                        Label {
                            Text(SettingsViewAccessibility.highContrastLabel)
                        } icon: {
                            Image(systemName: "circle.lefthalf.filled")
                        }
                    }
                    .tint(AppColors.resolvedAccent(highContrast: contrast))
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(SettingsViewAccessibility.highContrastLabel)
                    .accessibilityValue(settings.highContrastEnabled ? "On" : "Off")
                    .accessibilityIdentifier("settingsHighContrastToggle")

                    Button {
                        showTutorial = true
                    } label: {
                        Label {
                            Text(TutorialAccessibility.replayLabel)
                        } icon: {
                            Image(systemName: "book.fill")
                        }
                    }
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(TutorialAccessibility.replayLabel)
                    .accessibilityHint(SettingsViewAccessibility.showTutorialHint)
                    .accessibilityIdentifier("settingsShowTutorialButton")
                } header: {
                    Text(SettingsViewAccessibility.accessibilitySection)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.resolvedBackground(highContrast: contrast))
            .navigationTitle(SettingsViewAccessibility.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(SettingsViewAccessibility.doneLabel) {
                        dismiss()
                    }
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(SettingsViewAccessibility.doneLabel)
                    .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
        .environment(\.highContrast, contrast)
        .accessibilityIdentifier("settingsSheet")
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView {
                settings.completeTutorial()
                showTutorial = false
            }
            .environment(\.highContrast, contrast)
            .interactiveDismissDisabled()
        }
    }
}

// MARK: - Accessibility / Copy

enum SettingsViewAccessibility {
    static let title = String(localized: "settings.title", defaultValue: "Settings")
    static let doneLabel = String(localized: "settings.done", defaultValue: "Done")
    static let themeSection = String(localized: "settings.theme", defaultValue: "Theme")
    static let soundSection = String(localized: "settings.sound.section", defaultValue: "Sound")
    static let soundLabel = String(localized: "settings.sound", defaultValue: "Sound Effects")
    static let hapticsLabel = String(localized: "settings.haptics", defaultValue: "Haptic Feedback")
    static let accessibilitySection = String(
        localized: "settings.accessibility",
        defaultValue: "Accessibility"
    )
    static let highContrastLabel = String(
        localized: "settings.highContrast",
        defaultValue: "High Contrast"
    )
    static let openSettingsLabel = String(
        localized: "settings.open",
        defaultValue: "Settings"
    )
    static let openSettingsHint = String(
        localized: "settings.open.hint",
        defaultValue: "Opens theme, sound, and accessibility options"
    )
    static let showTutorialHint = String(
        localized: "settings.tutorial.hint",
        defaultValue: "Replays the how-to-play tutorial"
    )
}

#if DEBUG
#Preview {
    SettingsView()
        .environment(SettingsStore())
}
#endif
