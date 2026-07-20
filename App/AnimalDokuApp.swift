import SwiftUI

@main
struct AnimalDokuApp: App {
    private let configuration = AppLaunchConfiguration.current
    @State private var settingsStore: SettingsStore
    @State private var soundService: SoundService
    @State private var hapticService: HapticService
    @State private var saveGameStore: SaveGameStore

    init() {
        AppFontRegistration.registerBundledFonts()
        let settings = SettingsStore()
        let saves = SaveGameStore()
        // UI tests deep-link into a puzzle and must start from an empty board.
        if configuration.hasUITestPuzzleOverride {
            saves.clearAll()
        }
        _settingsStore = State(initialValue: settings)
        _soundService = State(initialValue: SoundService(settings: settings))
        _hapticService = State(initialValue: HapticService(settings: settings))
        _saveGameStore = State(initialValue: saves)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(configuration: configuration)
                .environment(settingsStore)
                .environment(soundService)
                .environment(hapticService)
                .environment(saveGameStore)
                .environment(\.highContrast, settingsStore.highContrastEnabled)
                .modifier(UITestReduceMotionModifier(enabled: configuration.reduceMotion))
                // App chrome is light-only (GDD); avoid a black window under NavigationStack in Dark Mode.
                .preferredColorScheme(.light)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background.ignoresSafeArea())
        }
    }
}
