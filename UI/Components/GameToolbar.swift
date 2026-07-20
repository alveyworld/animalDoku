import SwiftUI

/// Toolbar with Undo, Redo, Reset, and Hint actions for the game screen.
///
/// Presentation-only — state and callbacks are supplied by `GameViewModel` (P3.13).
struct GameToolbar: View {
    @Environment(\.highContrast) private var highContrast

    let canUndo: Bool
    let canRedo: Bool
    let canReset: Bool
    let canHint: Bool
    var hintsRemaining: Int = 3
    var isEnabled: Bool = true

    var onUndo: () -> Void = {}
    var onRedo: () -> Void = {}
    var onReset: () -> Void = {}
    var onHint: () -> Void = {}

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            ToolbarIconButton(
                symbol: "arrow.uturn.backward",
                label: GameToolbarAccessibility.undoLabel,
                hint: GameToolbarAccessibility.undoHint,
                accessibilityIdentifier: "toolbarUndo",
                isEnabled: isEnabled && canUndo,
                highContrast: highContrast,
                action: onUndo
            )

            ToolbarIconButton(
                symbol: "arrow.uturn.forward",
                label: GameToolbarAccessibility.redoLabel,
                hint: GameToolbarAccessibility.redoHint,
                accessibilityIdentifier: "toolbarRedo",
                isEnabled: isEnabled && canRedo,
                highContrast: highContrast,
                action: onRedo
            )

            ToolbarIconButton(
                symbol: "arrow.counterclockwise",
                label: GameToolbarAccessibility.resetLabel,
                hint: GameToolbarAccessibility.resetHint,
                accessibilityIdentifier: "toolbarReset",
                isEnabled: isEnabled && canReset,
                highContrast: highContrast,
                action: onReset
            )

            ToolbarIconButton(
                symbol: "lightbulb",
                label: GameToolbarAccessibility.hintLabel(remaining: hintsRemaining),
                hint: GameToolbarAccessibility.hintHint(remaining: hintsRemaining),
                accessibilityIdentifier: "toolbarHint",
                isEnabled: isEnabled && canHint,
                highContrast: highContrast,
                action: onHint
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("gameToolbar")
    }
}

// MARK: - Toolbar Button

private struct ToolbarIconButton: View {
    let symbol: String
    let label: String
    let hint: String
    let accessibilityIdentifier: String
    let isEnabled: Bool
    let highContrast: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(AppTypography.toolbar(highContrast: highContrast))
                .foregroundStyle(
                    isEnabled
                        ? AppColors.resolvedAccent(highContrast: highContrast)
                        : AppColors.resolvedSecondary(highContrast: highContrast)
                )
                .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .accessibilityHint(hint)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessibility

enum GameToolbarAccessibility {
    static let undoLabel = "Undo"
    static let undoHint = "Reverts the last move"
    static let redoLabel = "Redo"
    static let redoHint = "Reapplies the last undone move"
    static let resetLabel = "Reset puzzle"
    static let resetHint = "Clears the board and starts over"

    static func hintLabel(remaining: Int) -> String {
        remaining > 0 ? "Hint, \(remaining) remaining" : "Hint"
    }

    static func hintHint(remaining: Int) -> String {
        remaining > 0
            ? "Reveals one correct cell"
            : "No hints remaining"
    }
}

// MARK: - Previews

#if DEBUG
#Preview("All Enabled") {
    GameToolbar(
        canUndo: true,
        canRedo: true,
        canReset: true,
        canHint: true,
        hintsRemaining: 2
    )
    .padding(AppSpacing.md)
    .background(AppColors.background)
}

#Preview("Initial State") {
    GameToolbar(
        canUndo: false,
        canRedo: false,
        canReset: true,
        canHint: true,
        hintsRemaining: 3
    )
    .padding(AppSpacing.md)
    .background(AppColors.background)
}

#Preview("Board Locked") {
    GameToolbar(
        canUndo: true,
        canRedo: false,
        canReset: false,
        canHint: false,
        hintsRemaining: 0,
        isEnabled: false
    )
    .padding(AppSpacing.md)
    .background(AppColors.background)
}
#endif
