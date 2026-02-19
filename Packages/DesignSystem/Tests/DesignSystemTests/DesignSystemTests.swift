import Testing
@testable import DesignSystem

@Suite("DesignSystem Module")
struct DesignSystemModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(DesignSystemModule.version == "0.1.0")
    }
}
