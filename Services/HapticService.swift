import Foundation
import UIKit

/// Named game haptic events (calm, light feedback).
enum GameHaptic: Equatable {
    case place
    case win
}

protocol HapticPlaying: AnyObject {
    func play(_ haptic: GameHaptic)
}

/// Silent stand-in for tests and previews.
final class NoOpHapticService: HapticPlaying {
    func play(_ haptic: GameHaptic) {}
}

/// Plays subtle haptics for place / win, respecting `SettingsStore.hapticsEnabled` (P5.6).
///
/// Uses `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`. On Simulator
/// and devices without a Taptic Engine these APIs no-op safely.
@Observable
final class HapticService: HapticPlaying {
    private let settings: SettingsStore
    private let impactGenerator: UIImpactFeedbackGenerator
    private let notificationGenerator: UINotificationFeedbackGenerator
    private let applicationState: () -> UIApplication.State
    /// Test seam — when set, UIKit generators are skipped and this is invoked instead.
    private let playHandler: ((GameHaptic) -> Void)?

    init(
        settings: SettingsStore,
        applicationState: @escaping () -> UIApplication.State = {
            UIApplication.shared.applicationState
        },
        playHandler: ((GameHaptic) -> Void)? = nil
    ) {
        self.settings = settings
        self.applicationState = applicationState
        self.playHandler = playHandler
        self.impactGenerator = UIImpactFeedbackGenerator(style: .light)
        self.notificationGenerator = UINotificationFeedbackGenerator()
        impactGenerator.prepare()
        notificationGenerator.prepare()
    }

    func play(_ haptic: GameHaptic) {
        guard settings.hapticsEnabled else { return }
        guard applicationState() == .active else { return }

        if let playHandler {
            playHandler(haptic)
            return
        }

        switch haptic {
        case .place:
            impactGenerator.impactOccurred(intensity: 0.7)
            impactGenerator.prepare()
        case .win:
            notificationGenerator.notificationOccurred(.success)
            notificationGenerator.prepare()
        }
    }
}
