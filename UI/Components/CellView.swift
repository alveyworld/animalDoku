import SwiftUI

/// A single board cell. Presentation-only — no `GameSession` dependency.
///
/// Renders `CellState` (empty, blocked, animal) with optional selection and violation
/// overlays. Region background color is supplied by the parent (`BoardView`).
///
/// SwiftUI previews at the bottom demonstrate all visual states for design review.
struct CellView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.forceReduceMotion) private var forceReduceMotion
    @Environment(\.highContrast) private var highContrast

    let row: Int
    let col: Int
    let regionId: Int
    let state: CellState
    var isSelected: Bool = false
    var isViolating: Bool = false
    /// When true (completed puzzle), cells announce as locked.
    var isBoardLocked: Bool = false
    var animalIcon: Image = ThemeAsset.image(for: ThemeCatalog.defaultTheme)
    var animalIconColor: Color = AppColors.primary
    var selectionBorderColor: Color = AppColors.accent
    var onSingleTap: () -> Void = {}
    var onDoubleTap: () -> Void = {}

    private var reduceMotion: Bool {
        accessibilityReduceMotion || forceReduceMotion
    }

    private var resolvedIconColor: Color {
        highContrast ? AppColors.resolvedPrimary(highContrast: true) : animalIconColor
    }

    private var resolvedSelectionColor: Color {
        highContrast ? AppColors.resolvedAccent(highContrast: true) : selectionBorderColor
    }

    private var resolvedErrorColor: Color {
        AppColors.resolvedError(highContrast: highContrast)
    }

    var body: some View {
        cellContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                guard !isBoardLocked else { return }
                onDoubleTap()
            }
            .onTapGesture(count: 1) {
                guard !isBoardLocked else { return }
                onSingleTap()
            }
            .frame(minWidth: TouchTarget.minimum, minHeight: TouchTarget.minimum)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(CellViewAccessibility.label(
                row: row,
                col: col,
                regionId: regionId,
                state: state,
                isViolating: isViolating,
                isSelected: isSelected,
                isBoardLocked: isBoardLocked
            ))
            .accessibilityHint(CellViewAccessibility.hint(for: state, isBoardLocked: isBoardLocked))
            .accessibilityIdentifier("cell_\(row)_\(col)")
            .accessibilityAddTraits(CellViewAccessibility.traits(
                isSelected: isSelected,
                isBoardLocked: isBoardLocked
            ))
            .accessibilityAction(named: Text(CellViewAccessibility.markActionName(for: state))) {
                guard !isBoardLocked else { return }
                onSingleTap()
            }
            .accessibilityAction(named: Text(CellViewAccessibility.placeActionName(for: state))) {
                guard !isBoardLocked else { return }
                onDoubleTap()
            }
    }

    private var cellContent: some View {
        ZStack {
            if isViolating {
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                    .fill(resolvedErrorColor.opacity(highContrast ? 0.28 : 0.18))
            }

            stateContent
                .animation(Motion.cellStateAnimation(reduceMotion: reduceMotion), value: state)

            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .empty:
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        case .blocked:
            BlockedMark(color: resolvedIconColor)
                .transition(Motion.cellContentTransition(reduceMotion: reduceMotion))
        case .animal:
            animalIcon
                .resizable()
                .scaledToFit()
                .foregroundStyle(resolvedIconColor)
                .padding(AppSpacing.xs)
                .accessibilityHidden(true)
                .transition(Motion.cellContentTransition(reduceMotion: reduceMotion))
        }
    }

    private var borderColor: Color {
        if isViolating {
            return resolvedErrorColor
        }
        if isSelected {
            return resolvedSelectionColor
        }
        return .clear
    }

    private var borderWidth: CGFloat {
        guard isSelected || isViolating else { return 0 }
        return AppColors.borderWeight(highContrast: highContrast) + (highContrast ? 0 : 1)
    }
}

// MARK: - Blocked X mark

/// Diagonal X stroke — shape-based, not color alone (GDD accessibility).
private struct BlockedMark: View {
    var color: Color = AppColors.primary

    var body: some View {
        GeometryReader { geometry in
            let inset = geometry.size.width * 0.22
            let size = geometry.size

            Path { path in
                path.move(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: size.width - inset, y: size.height - inset))
                path.move(to: CGPoint(x: size.width - inset, y: inset))
                path.addLine(to: CGPoint(x: inset, y: size.height - inset))
            }
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
        }
        .padding(AppSpacing.xs)
        .accessibilityHidden(true)
    }
}

// MARK: - Accessibility

enum CellViewAccessibility {
    static func label(
        row: Int,
        col: Int,
        regionId: Int,
        state: CellState,
        isViolating: Bool,
        isSelected: Bool = false,
        isBoardLocked: Bool = false
    ) -> String {
        let position = "Row \(row + 1), Column \(col + 1), Region \(regionId)"
        var parts = [position, stateLabel(for: state, isViolating: isViolating)]
        if isSelected {
            parts.append("selected")
        }
        if isBoardLocked {
            parts.append("locked")
        }
        return parts.joined(separator: ", ")
    }

    static func hint(for state: CellState, isBoardLocked: Bool) -> String {
        guard !isBoardLocked else { return "Board locked" }
        switch state {
        case .empty:
            return "Tap to mark, double tap to place animal"
        case .blocked:
            return "Tap to clear mark, double tap to place animal"
        case .animal:
            return "Double tap to remove animal"
        }
    }

    static func markActionName(for state: CellState) -> String {
        switch state {
        case .blocked: "Clear mark"
        case .empty, .animal: "Mark"
        }
    }

    static func placeActionName(for state: CellState) -> String {
        switch state {
        case .animal: "Remove animal"
        case .empty, .blocked: "Place animal"
        }
    }

    static func traits(isSelected: Bool, isBoardLocked: Bool) -> AccessibilityTraits {
        var traits: AccessibilityTraits = .isButton
        if isSelected {
            traits.insert(.isSelected)
        }
        _ = isBoardLocked
        return traits
    }

    private static func stateLabel(for state: CellState, isViolating: Bool) -> String {
        let base: String
        switch state {
        case .empty: base = "empty"
        case .blocked: base = "blocked"
        case .animal: base = "animal"
        }
        return isViolating ? "\(base), violation" : base
    }
}

// MARK: - Previews

#if DEBUG
private struct CellPreviewTile: View {
    let title: String
    let row: Int
    let col: Int
    let regionId: Int
    let state: CellState
    var isSelected: Bool = false
    var isViolating: Bool = false

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            CellView(
                row: row,
                col: col,
                regionId: regionId,
                state: state,
                isSelected: isSelected,
                isViolating: isViolating,
                animalIcon: ThemeAsset.image(for: "frogs")
            )
            .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
            .background(AppColors.regionColor(at: regionId))
        }
    }
}

#Preview("Cell States") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 3),
            spacing: AppSpacing.md
        ) {
            CellPreviewTile(title: "Empty", row: 0, col: 0, regionId: 0, state: .empty)
            CellPreviewTile(title: "Blocked", row: 0, col: 1, regionId: 1, state: .blocked)
            CellPreviewTile(title: "Animal", row: 0, col: 2, regionId: 2, state: .animal)

            CellPreviewTile(title: "Selected", row: 1, col: 0, regionId: 3, state: .empty, isSelected: true)
            CellPreviewTile(
                title: "Violation",
                row: 1,
                col: 1,
                regionId: 4,
                state: .animal,
                isViolating: true
            )
            CellPreviewTile(
                title: "Sel + Violation",
                row: 1,
                col: 2,
                regionId: 5,
                state: .blocked,
                isSelected: true,
                isViolating: true
            )
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}

#Preview("Region Contrast") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.xs), count: 4),
            spacing: AppSpacing.xs
        ) {
            ForEach(0..<8, id: \.self) { regionId in
                CellView(
                    row: 0,
                    col: regionId,
                    regionId: regionId,
                    state: regionId.isMultiple(of: 2) ? .blocked : .animal,
                    animalIcon: ThemeAsset.image(for: "frogs")
                )
                .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
                .background(AppColors.regionColor(at: regionId))
            }
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}
#endif
