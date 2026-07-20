import XCTest
@testable import AnimalDoku

/// Guards PrivacyInfo.xcprivacy contents for App Store / TestFlight (P7.1).
final class PrivacyManifestTests: XCTestCase {
    func testPrivacyManifestIsBundledAndValid() throws {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"),
            "PrivacyInfo.xcprivacy must be in the app bundle"
        )

        let data = try Data(contentsOf: url)
        let object = try PropertyListSerialization.propertyList(from: data, format: nil)
        let root = try XCTUnwrap(object as? [String: Any])

        XCTAssertEqual(root["NSPrivacyTracking"] as? Bool, false)

        let trackingDomains = try XCTUnwrap(root["NSPrivacyTrackingDomains"] as? [Any])
        XCTAssertTrue(trackingDomains.isEmpty)

        let collected = try XCTUnwrap(root["NSPrivacyCollectedDataTypes"] as? [Any])
        XCTAssertTrue(collected.isEmpty)

        let accessed = try XCTUnwrap(root["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let byType = Dictionary(
            uniqueKeysWithValues: accessed.compactMap { entry -> (String, [String])? in
                guard let type = entry["NSPrivacyAccessedAPIType"] as? String,
                      let reasons = entry["NSPrivacyAccessedAPITypeReasons"] as? [String] else {
                    return nil
                }
                return (type, reasons)
            }
        )

        XCTAssertEqual(
            byType["NSPrivacyAccessedAPICategoryUserDefaults"],
            ["CA92.1"],
            "SettingsStore UserDefaults must declare CA92.1"
        )
        XCTAssertEqual(
            byType["NSPrivacyAccessedAPICategorySystemBootTime"],
            ["35F9.1"],
            "TimerService systemUptime must declare 35F9.1"
        )
        XCTAssertEqual(byType.count, 2, "Only declared required-reason categories should appear")
    }
}
