import SwiftUI

/// Gaze offset for look-around (points relative to cell).
struct AnimalGaze: Equatable {
    var offset: CGSize
    var tiltDegrees: Double

    static let neutral = AnimalGaze(offset: .zero, tiltDegrees: 0)
}

enum AnimalHeadPose: Equatable {
    case neutral
    case looking(AnimalGaze)
}

/// Cartoon theme head for board cells and theme picker (P8.3).
///
/// Look-around uses a light head tilt/offset (full-head art includes baked pupils).
struct AnimalHeadView: View {
    let theme: Theme
    /// Bumped when this cell should play look-around (place only).
    var lookAroundTrigger: Int = 0
    var reduceMotion: Bool = false

    @State private var pose: AnimalHeadPose = .neutral
    @State private var lookAroundTask: Task<Void, Never>?

    var body: some View {
        ThemeAsset.image(for: theme)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(currentGaze.tiltDegrees))
            .offset(currentGaze.offset)
            .accessibilityHidden(true)
            .onChange(of: lookAroundTrigger) { _, newValue in
                guard newValue > 0 else { return }
                playLookAroundIfNeeded()
            }
            .onDisappear {
                lookAroundTask?.cancel()
                lookAroundTask = nil
            }
    }

    private var currentGaze: AnimalGaze {
        switch pose {
        case .neutral: .neutral
        case .looking(let gaze): gaze
        }
    }

    private func playLookAroundIfNeeded() {
        lookAroundTask?.cancel()
        guard Motion.allowsLookAround(reduceMotion: reduceMotion) else {
            pose = .neutral
            return
        }

        lookAroundTask = Task { @MainActor in
            let steps: [AnimalGaze] = [
                AnimalGaze(offset: CGSize(width: -3, height: 0.5), tiltDegrees: -8),
                AnimalGaze(offset: CGSize(width: 3.5, height: -0.5), tiltDegrees: 9),
                AnimalGaze(offset: CGSize(width: -1.5, height: 1), tiltDegrees: -4),
                .neutral,
            ]
            let stepDuration = Motion.lookAroundDuration / Double(steps.count)
            for step in steps {
                guard !Task.isCancelled else { return }
                withAnimation(Motion.lookAroundStepCurve) {
                    pose = .looking(step)
                }
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            }
            pose = .neutral
        }
    }
}
