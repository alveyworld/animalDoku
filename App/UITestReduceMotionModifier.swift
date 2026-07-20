import SwiftUI

private struct ForceReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// When true (UI-test `-uiTestReduceMotion`), treat motion like Reduce Motion is on.
    var forceReduceMotion: Bool {
        get { self[ForceReduceMotionKey.self] }
        set { self[ForceReduceMotionKey.self] = newValue }
    }
}

/// Applies `forceReduceMotion` when `-uiTestReduceMotion` is present (P6.2).
struct UITestReduceMotionModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        content.environment(\.forceReduceMotion, enabled)
    }
}
