import Testing
@testable import Domain

@Suite("Domain Module")
struct DomainModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(DomainModule.version == "0.1.0")
    }
}
