import XCTest
@testable import Utilities
@testable import Domain

final class CBTAppIntegrationTests: XCTestCase {
    func testUtilitiesPackageAccessible() {
        XCTAssertEqual(UtilitiesModule.version, "0.1.0")
    }

    func testDomainPackageAccessible() {
        XCTAssertEqual(DomainModule.version, "0.1.0")
    }

    func testLoggerCreation() {
        let logger = CBTLogger.logger(for: .app)
        XCTAssertEqual(logger.category, .app)
    }
}
