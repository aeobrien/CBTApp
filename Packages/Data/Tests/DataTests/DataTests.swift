import Testing
@testable import Data

@Suite("Data Module")
struct DataModuleTests {
    @Test("Module initialises with correct version")
    func moduleVersion() {
        #expect(DataModule.version == "0.1.0")
    }
}
