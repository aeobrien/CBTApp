import Testing
@testable import Services

@Suite("Services Module")
struct ServicesModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(ServicesModule.version == "0.1.0")
    }
}
