import SwiftUI

/// Maps puzzle region IDs to SwiftUI colors.
///
/// P8.1: fills come from `AppColors` accessible tokens by `regionId`.
/// Puzzle JSON `region.color` hex is ignored so the catalog stays one source of truth.
struct RegionColorMap {
    private let colorsByRegionId: [Int: Color]
    private let highContrast: Bool

    init(regions: [Region], highContrast: Bool = false) {
        self.highContrast = highContrast
        var map: [Int: Color] = [:]
        for region in regions {
            map[region.id] = AppColors.regionColor(at: region.id, highContrast: highContrast)
        }
        colorsByRegionId = map
    }

    func color(for regionId: Int) -> Color {
        colorsByRegionId[regionId]
            ?? AppColors.regionColor(at: regionId, highContrast: highContrast)
    }

    /// Parses `#RRGGBB` hex strings into SwiftUI colors (tests / token helpers).
    static func parseHex(_ hex: String) -> Color? {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }
        guard sanitized.count == 6, let value = UInt64(sanitized, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}
