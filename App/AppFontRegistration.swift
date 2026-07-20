import CoreText
import Foundation
import UIKit

/// Registers bundled custom fonts (P8.2 Vaseline Extra for board marks).
enum AppFontRegistration {
    static func registerBundledFonts() {
        register(resource: "VaselineExtra", extension: "ttf")
    }

    private static func register(resource: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else {
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }

    /// Resolves the PostScript / family name that actually loads on device.
    static func resolvedFontName(candidates: [String], size: CGFloat = 12) -> String? {
        candidates.first { UIFont(name: $0, size: size) != nil }
    }
}
