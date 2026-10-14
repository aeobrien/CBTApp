import Testing
@testable import Utilities

@Suite("Utilities Module")
struct UtilitiesModuleTests {
    @Test("Module initialises with correct version")
    func utilitiesModuleVersion() {
        #expect(UtilitiesModule.version == "0.1.0")
    }
}
