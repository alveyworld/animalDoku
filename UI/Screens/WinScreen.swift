import SwiftUI
import UIKit

/// Win overlay shown when the puzzle is solved.
///
/// v0.1: title + Play Again only. Elapsed time and hints used deferred to P4.6.
struct WinScreen: View {
    var onPlayAgain: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.lg) {
                Text(WinScreenAccessibility.title)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Button("Play Again", action: onPlayAgain)
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)
                    .frame(minHeight: TouchTarget.minimum)
                    .accessibilityLabel(WinScreenAccessibility.playAgainLabel)
                    .accessibilityIdentifier("playAgainButton")
            }
            .padding(AppSpacing.xl)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("winScreen")
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: WinScreenAccessibility.title
            )
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
    WinScreen()
        .background(AppColors.background)
}
#endif
