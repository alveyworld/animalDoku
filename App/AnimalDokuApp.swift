import SwiftUI

@main
struct AnimalDokuApp: App {
    private let configuration = AppLaunchConfiguration.current

    var body: some Scene {
        WindowGroup {
            ContentView(configuration: configuration)
        }
    }
}
