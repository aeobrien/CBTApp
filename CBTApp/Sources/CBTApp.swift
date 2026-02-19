import SwiftUI
import Utilities

@main
struct CBTApp: App {
    private let logger = CBTLogger.logger(for: .app)

    init() {
        logger.info("App launched")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
