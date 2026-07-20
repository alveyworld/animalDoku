import Foundation

/// Launch-time configuration read from process arguments and defaults.
///
/// UI-test / rollback overrides are **DEBUG-only** (P7.2) so Release / TestFlight
/// builds always launch the normal Home → Game flow:
/// - `-uiTestPuzzle <name>` — load a specific bundled puzzle (skips Home)
/// - `-uiTestReduceMotion` — hint for reduced-motion UI (P6.2)
/// - `-disableHomeScreen` — launch straight into the default/game puzzle (P4.8 rollback)
struct AppLaunchConfiguration: Equatable {
    static let defaultPuzzleName = "puzzle-001"

    #if DEBUG
    static let uiTestPuzzleFlag = "-uiTestPuzzle"
    static let uiTestReduceMotionFlag = "-uiTestReduceMotion"
    static let disableHomeScreenFlag = "-disableHomeScreen"
    #endif

    let puzzleName: String
    let reduceMotion: Bool
    /// When true, ContentView presents Home as the root (v1.1). Disabled by rollback flag.
    let homeScreenEnabled: Bool
    /// True when `-uiTestPuzzle` was provided with a value (UI tests skip Home).
    let hasUITestPuzzleOverride: Bool

    /// Home is shown unless disabled for rollback or overridden by UI-test deep link.
    var launchesToHome: Bool {
        homeScreenEnabled && !hasUITestPuzzleOverride
    }

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        #if DEBUG
        puzzleName = Self.puzzleName(from: arguments)
        reduceMotion = arguments.contains(Self.uiTestReduceMotionFlag)
        homeScreenEnabled = !arguments.contains(Self.disableHomeScreenFlag)
        hasUITestPuzzleOverride = Self.hasUITestPuzzleOverride(in: arguments)
        #else
        puzzleName = Self.defaultPuzzleName
        reduceMotion = false
        homeScreenEnabled = true
        hasUITestPuzzleOverride = false
        #endif
    }

    static var current: AppLaunchConfiguration {
        AppLaunchConfiguration()
    }

    #if DEBUG
    static func puzzleName(from arguments: [String]) -> String {
        guard let index = arguments.firstIndex(of: uiTestPuzzleFlag),
              arguments.indices.contains(index + 1) else {
            return defaultPuzzleName
        }
        return arguments[index + 1]
    }

    static func hasUITestPuzzleOverride(in arguments: [String]) -> Bool {
        guard let index = arguments.firstIndex(of: uiTestPuzzleFlag),
              arguments.indices.contains(index + 1) else {
            return false
        }
        return true
    }
    #endif
}
