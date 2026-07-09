import SwiftUI

/// Root content view: loads the launch puzzle and presents `GameView`.
struct ContentView: View {
    private let configuration: AppLaunchConfiguration
    private let puzzleResult: Result<Puzzle, PuzzleLoaderError>

    init(configuration: AppLaunchConfiguration = .current) {
        self.configuration = configuration
        let loader = PuzzleLoader()
        do {
            puzzleResult = .success(try loader.load(named: configuration.puzzleName))
        } catch let error as PuzzleLoaderError {
            puzzleResult = .failure(error)
        } catch {
            puzzleResult = .failure(.decodingFailed(error.localizedDescription))
        }
    }

    var body: some View {
        Group {
            switch puzzleResult {
            case .success(let puzzle):
                GameView(puzzle: puzzle)
                    .accessibilityIdentifier("gameView")
            case .failure(let error):
                PuzzleLoadErrorView(message: Self.message(for: error))
            }
        }
        .background(AppColors.background)
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
    ContentView()
}

#if DEBUG
#Preview("Load Error") {
    ContentView(configuration: AppLaunchConfiguration(arguments: ["-uiTestPuzzle", "missing-puzzle"]))
}
#endif
