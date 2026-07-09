import Foundation

/// Launch-time configuration read from process arguments and defaults.
///
/// Supports UI test overrides (P6.2):
/// - `-uiTestPuzzle <name>` — load a specific bundled puzzle
/// - `-uiTestReduceMotion` — hint for reduced-motion UI (P6.2)
struct AppLaunchConfiguration: Equatable {
    static let defaultPuzzleName = "puzzle-001"
    static let uiTestPuzzleFlag = "-uiTestPuzzle"
    static let uiTestReduceMotionFlag = "-uiTestReduceMotion"

    let puzzleName: String
    let reduceMotion: Bool

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        puzzleName = Self.puzzleName(from: arguments)
        reduceMotion = arguments.contains(Self.uiTestReduceMotionFlag)
    }

    static var current: AppLaunchConfiguration {
        AppLaunchConfiguration()
    }

    static func puzzleName(from arguments: [String]) -> String {
        guard let index = arguments.firstIndex(of: uiTestPuzzleFlag),
              arguments.indices.contains(index + 1) else {
            return defaultPuzzleName
        }
        return arguments[index + 1]
    }
}
