import SwiftUI
import UIKit

/// Segmented control for switching between Place and Mark input modes.
///
/// Formal Rules Interaction Model:
/// | Mode  | Tap empty   | Tap blocked | Tap animal    |
/// | Place | Place animal| No effect   | Remove animal |
/// | Mark  | Toggle X    | Clear X     | No effect     |
struct InputModeToggle: View {
    @Binding var mode: InputMode
    var isEnabled: Bool = true

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Picker("Input mode", selection: $mode) {
                Label {
                    Text("Place")
                } icon: {
                    Image(systemName: "pawprint.fill")
                }
                .tag(InputMode.place)

                Label {
                    Text("Mark")
                } icon: {
                    Image(systemName: "xmark")
                }
                .tag(InputMode.mark)
            }
            .pickerStyle(.segmented)
            .tint(AppColors.accent)
            .disabled(!isEnabled)
            .frame(minHeight: TouchTarget.minimum)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Input mode")
            .accessibilityValue(InputModeToggleAccessibility.valueLabel(for: mode))
            .accessibilityHint(InputModeToggleAccessibility.hint(for: mode))
            .accessibilityAddTraits(.isButton)
            .onChange(of: mode) { _, newMode in
                UIAccessibility.post(
                    notification: .announcement,
                    argument: InputModeToggleAccessibility.announcement(for: newMode)
                )
            }

            Text(InputModeToggleAccessibility.hint(for: mode))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Accessibility

enum InputModeToggleAccessibility {
    static func valueLabel(for mode: InputMode) -> String {
        switch mode {
        case .place: "Place mode"
        case .mark: "Mark mode"
        }
    }

    static func hint(for mode: InputMode) -> String {
        switch mode {
        case .place: "Tap cells to place animals"
        case .mark: "Tap cells to mark impossible"
        }
    }

    static func announcement(for mode: InputMode) -> String {
        valueLabel(for: mode)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Place Mode") {
    InputModeTogglePreview(initialMode: .place)
}

#Preview("Mark Mode") {
    InputModeTogglePreview(initialMode: .mark)
}

#Preview("Disabled") {
    InputModeTogglePreview(initialMode: .place, isEnabled: false)
}

private struct InputModeTogglePreview: View {
    @State private var mode: InputMode

    let isEnabled: Bool

    init(initialMode: InputMode, isEnabled: Bool = true) {
        _mode = State(initialValue: initialMode)
        self.isEnabled = isEnabled
    }

    var body: some View {
        InputModeToggle(mode: $mode, isEnabled: isEnabled)
            .padding(AppSpacing.md)
            .background(AppColors.background)
    }
}
#endif
