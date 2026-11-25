import Testing
@testable import Features

@Suite("Features Module")
struct FeaturesModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(FeaturesModule.version == "0.1.0")
    }
}
