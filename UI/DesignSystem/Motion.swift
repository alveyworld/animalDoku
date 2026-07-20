import SwiftUI

/// Centralized animation policy for calm, polished motion (P5.1 / P5.2).
enum Motion {
    /// Gentle place animation (~200ms, within GDD 150–250ms target).
    static let placeDuration: TimeInterval = 0.2

    /// Slightly quicker remove so the board feels responsive.
    static let removeDuration: TimeInterval = 0.18

    /// Win overlay entrance (~280ms, within ~300ms GDD target).
    static let winDuration: TimeInterval = 0.28

    /// Full look-around sequence after placing an animal (P8.3).
    static let lookAroundDuration: TimeInterval = 1.1

    /// Soft scale used when the win card animates in.
    static let winEntranceScale: CGFloat = 0.94

    static let placeCurve = Animation.easeOut(duration: placeDuration)
    static let removeCurve = Animation.easeIn(duration: removeDuration)
    static let winCurve = Animation.easeOut(duration: winDuration)
    static let lookAroundStepCurve = Animation.easeInOut(duration: 0.22)

    /// Cell state changes use place timing for both directions unless Reduce Motion is on.
    static func cellStateAnimation(reduceMotion: Bool) -> Animation? {
        respectingReduceMotion(reduceMotion, curve: placeCurve)
    }

    /// Win overlay entrance — `nil` when Reduce Motion is on (instant appear).
    static func winOverlayAnimation(reduceMotion: Bool) -> Animation? {
        respectingReduceMotion(reduceMotion, curve: winCurve)
    }

    /// Whether look-around may run (P8.3).
    static func allowsLookAround(reduceMotion: Bool) -> Bool {
        !reduceMotion
    }

    /// Returns `nil` when Reduce Motion is enabled so state snaps instantly (cross-fade only via transition).
    static func respectingReduceMotion(_ reduceMotion: Bool, curve: Animation) -> Animation? {
        reduceMotion ? nil : curve
    }

    /// Place/remove transition for animal and blocked marks.
    static func cellContentTransition(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion {
            return .opacity
        }
        return .scale(scale: 0.88).combined(with: .opacity)
    }
}
