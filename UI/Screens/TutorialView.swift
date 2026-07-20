import SwiftUI

/// First-launch / replayable onboarding pager (P5.5).
struct TutorialView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.forceReduceMotion) private var forceReduceMotion
    @Environment(\.highContrast) private var highContrast

    var onFinished: () -> Void = {}

    @State private var pageIndex = 0

    private var steps: [TutorialStep] { TutorialCatalog.steps }
    private var isLastStep: Bool { pageIndex >= steps.count - 1 }
    private var reduceMotion: Bool {
        accessibilityReduceMotion || forceReduceMotion
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                TabView(selection: $pageIndex) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        TutorialStepPage(step: step, highContrast: highContrast)
                            .tag(index)
                            .padding(.horizontal, AppSpacing.md)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.2),
                    value: pageIndex
                )
                .accessibilityIdentifier("tutorialPager")

                primaryButton
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.md)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.resolvedBackground(highContrast: highContrast))
            .navigationTitle(TutorialAccessibility.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(TutorialAccessibility.skipLabel, action: finish)
                        .frame(minHeight: TouchTarget.minimum)
                        .accessibilityIdentifier("tutorialSkipButton")
                }
            }
        }
        .accessibilityIdentifier("tutorialView")
    }

    private var primaryButton: some View {
        Button(action: advanceOrFinish) {
            Text(isLastStep ? TutorialAccessibility.startLabel : TutorialAccessibility.nextLabel)
                .font(AppTypography.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: TouchTarget.minimum)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.resolvedAccent(highContrast: highContrast))
        .accessibilityIdentifier(isLastStep ? "tutorialStartButton" : "tutorialNextButton")
    }

    private func advanceOrFinish() {
        if isLastStep {
            finish()
        } else {
            pageIndex += 1
        }
    }

    private func finish() {
        onFinished()
    }
}

private struct TutorialStepPage: View {
    let step: TutorialStep
    let highContrast: Bool

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer(minLength: AppSpacing.sm)

            Image(systemName: step.systemImage)
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(AppColors.resolvedAccent(highContrast: highContrast))
                .accessibilityHidden(true)

            Text(step.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.resolvedPrimary(highContrast: highContrast))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(step.body)
                .font(AppTypography.body(highContrast: highContrast))
                .foregroundStyle(AppColors.resolvedSecondary(highContrast: highContrast))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: AppSpacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tutorialStep_\(step.id)")
    }
}

// MARK: - Accessibility / Copy

enum TutorialAccessibility {
    static let navigationTitle = String(localized: "tutorial.navTitle", defaultValue: "How to Play")
    static let skipLabel = String(localized: "tutorial.skip", defaultValue: "Skip")
    static let nextLabel = String(localized: "tutorial.next", defaultValue: "Next")
    static let startLabel = String(localized: "tutorial.start", defaultValue: "Start Playing")
    static let replayLabel = String(
        localized: "tutorial.replay",
        defaultValue: "Show Tutorial"
    )
}

#if DEBUG
#Preview {
    TutorialView()
        .environment(\.highContrast, false)
}
#endif
