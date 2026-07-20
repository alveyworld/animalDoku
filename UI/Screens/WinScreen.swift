import SwiftUI
import UIKit

/// Win overlay shown when the puzzle is solved.
struct WinScreen: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.forceReduceMotion) private var forceReduceMotion
    @Environment(\.highContrast) private var highContrast

    var elapsedSeconds: Int = 0
    var onPlayAgain: () -> Void = {}

    @State private var isPresented = false

    private var reduceMotion: Bool {
        accessibilityReduceMotion || forceReduceMotion
    }

    var body: some View {
        ZStack {
            Color.black.opacity(isPresented ? (highContrast ? 0.4 : 0.25) : 0)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.lg) {
                Text(WinScreenAccessibility.title)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.resolvedPrimary(highContrast: highContrast))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                Text(ElapsedTimeFormatting.display(seconds: elapsedSeconds))
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.resolvedSecondary(highContrast: highContrast))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(ElapsedTimeFormatting.accessibilityLabel(seconds: elapsedSeconds))
                    .accessibilityIdentifier("winElapsedTime")

                Button("Play Again", action: onPlayAgain)
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.resolvedAccent(highContrast: highContrast))
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(WinScreenAccessibility.playAgainLabel)
                    .accessibilityIdentifier("playAgainButton")
            }
            .padding(AppSpacing.xl)
            .background(AppColors.resolvedSurface(highContrast: highContrast))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge)
                    .strokeBorder(
                        AppColors.resolvedBorder(highContrast: highContrast),
                        lineWidth: highContrast ? AppColors.HighContrast.borderWeight : 0
                    )
            )
            .shadow(color: .black.opacity(highContrast ? 0.12 : 0.08), radius: 8, y: 2)
            .padding(AppSpacing.lg)
            .scaleEffect(cardScale)
            .opacity(isPresented ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("winScreen")
        .onAppear {
            presentWinOverlay()
            UIAccessibility.post(
                notification: .announcement,
                argument: WinScreenAccessibility.title
            )
        }
    }

    private var cardScale: CGFloat {
        if reduceMotion || isPresented {
            return 1
        }
        return Motion.winEntranceScale
    }

    private func presentWinOverlay() {
        guard !isPresented else { return }
        if let animation = Motion.winOverlayAnimation(reduceMotion: reduceMotion) {
            withAnimation(animation) {
                isPresented = true
            }
        } else {
            isPresented = true
        }
    }
}

// MARK: - Accessibility

enum WinScreenAccessibility {
    static let title = "Puzzle Complete!"
    static let playAgainLabel = "Play again"
}

#if DEBUG
#Preview {
    WinScreen(elapsedSeconds: 125)
        .background(AppColors.background)
}
#endif
