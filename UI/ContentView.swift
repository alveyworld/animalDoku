import SwiftUI

/// Root content view: Home (v1.1) or direct Game for UI tests / rollback.
struct ContentView: View {
    @Environment(SaveGameStore.self) private var saveStore
    @Environment(SettingsStore.self) private var settings
    private let configuration: AppLaunchConfiguration
    private let catalog: [Puzzle]
    private let directPuzzleResult: Result<Puzzle, PuzzleLoaderError>?

    @State private var showTutorial = false

    init(configuration: AppLaunchConfiguration = .current) {
        self.configuration = configuration
        let loader = PuzzleLoader()
        catalog = HomeCatalog.playable(loader.loadAvailablePuzzles())

        if configuration.launchesToHome {
            directPuzzleResult = nil
        } else {
            do {
                directPuzzleResult = .success(try loader.load(named: configuration.puzzleName))
            } catch let error as PuzzleLoaderError {
                directPuzzleResult = .failure(error)
            } catch {
                directPuzzleResult = .failure(.decodingFailed(error.localizedDescription))
            }
        }
    }

    var body: some View {
        Group {
            if configuration.launchesToHome {
                NavigationStack {
                    HomeView(puzzles: catalog)
                }
            } else {
                directGameContent
            }
        }
        .background(AppColors.resolvedBackground(highContrast: settings.highContrastEnabled))
        .environment(\.highContrast, settings.highContrastEnabled)
        .onAppear {
            presentTutorialIfNeeded()
        }
        .onChange(of: settings.tutorialCompleted) { _, completed in
            if completed {
                showTutorial = false
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView {
                settings.completeTutorial()
                showTutorial = false
            }
            .environment(\.highContrast, settings.highContrastEnabled)
            .interactiveDismissDisabled()
        }
    }

    private func presentTutorialIfNeeded() {
        showTutorial = TutorialCatalog.shouldPresent(
            tutorialCompleted: settings.tutorialCompleted,
            configuration: configuration
        )
    }

    @ViewBuilder
    private var directGameContent: some View {
        switch directPuzzleResult {
        case .success(let puzzle):
            GameView(puzzle: puzzle, saveStore: saveStore)
                // Contain children so cell/board/toolbar identifiers are not overwritten by `gameView`.
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("gameView")
        case .failure(let error):
            PuzzleLoadErrorView(message: Self.message(for: error))
        case .none:
            PuzzleLoadErrorView(message: "Puzzle could not be loaded.")
        }
    }

    private static func message(for error: PuzzleLoaderError) -> String {
        switch error {
        case .fileNotFound(let name):
            "Puzzle file not found: \(name)"
        case .decodingFailed(let details):
            "Puzzle data is invalid: \(details)"
        case .regionsDoNotPartition:
            "Puzzle regions do not cover the board correctly."
        case .nonContiguousRegionIds:
            "Puzzle region IDs are invalid."
        case .solutionLengthMismatch(let expected, let got):
            "Puzzle solution length mismatch. Expected \(expected), got \(got)."
        }
    }
}

#Preview {
    let settings = SettingsStore()
    return ContentView()
        .environment(settings)
        .environment(SoundService(settings: settings))
        .environment(HapticService(settings: settings))
        .environment(SaveGameStore())
}

#if DEBUG
#Preview("Load Error") {
    let settings = SettingsStore()
    return ContentView(
        configuration: AppLaunchConfiguration(
            arguments: ["-uiTestPuzzle", "missing-puzzle"]
        )
    )
        .environment(settings)
        .environment(SoundService(settings: settings))
        .environment(HapticService(settings: settings))
        .environment(SaveGameStore())
}
#endif
