import SwiftUI

/// Shown when the bundled puzzle cannot be loaded at launch.
struct PuzzleLoadErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Unable to Load Puzzle")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primary)
                .accessibilityAddTraits(.isHeader)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .accessibilityIdentifier("puzzleLoadError")
    }
}

#if DEBUG
#Preview {
    PuzzleLoadErrorView(message: "Puzzle file not found: puzzle-001")
}
#endif
