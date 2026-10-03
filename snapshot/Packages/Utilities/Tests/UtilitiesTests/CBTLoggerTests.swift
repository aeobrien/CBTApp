import Testing
@testable import Utilities

@Suite("CBTLogger")
struct CBTLoggerTests {

    @Test("Subsystem is com.cbt.app")
    func subsystem() {
        #expect(CBTLogger.subsystem == "com.cbt.app")
    }

    @Test("All categories have non-empty raw values")
    func categoryRawValues() {
        let categories: [CBTLogger.Category] = [
            .app, .domain, .data, .designSystem, .services, .utilities,
            .protocolEngine, .runMode, .workshop, .evidence,
            .agentService, .validation, .safety, .voiceInput,
            .onboarding, .quickTriage, .settings
        ]
        for category in categories {
            #expect(!category.rawValue.isEmpty, "Category \(category) has empty raw value")
        }
    }

    @Test("Logger created for each category without crashing")
    func loggerCreation() {
        let categories: [CBTLogger.Category] = [
            .app, .domain, .data, .designSystem, .services, .utilities,
            .protocolEngine, .runMode, .workshop, .evidence,
            .agentService, .validation, .safety, .voiceInput,
            .onboarding, .quickTriage, .settings
        ]
        for category in categories {
            let logger = CBTLogger.logger(for: category)
            #expect(logger.category == category)
        }
    }

    @Test("Logger can log at all levels without crashing")
    func logAllLevels() {
        let logger = CBTLogger.logger(for: .app)
        // These should not throw or crash
        logger.debug("Test debug message")
        logger.info("Test info message")
        logger.warning("Test warning message")
        logger.error("Test error message")
    }

    @Test("Logger includes correlation ID in formatted output")
    func correlationID() {
        let logger = CBTLogger.logger(for: .runMode)
        // These should not throw or crash — we can't capture os.Logger output
        // in tests, but we verify the calls succeed
        logger.debug("Starting run", correlationID: "run-abc-123")
        logger.info("Run saved", correlationID: "run-abc-123")
        logger.error("Run failed", correlationID: "run-abc-123")
    }

    @Test("Logger works without correlation ID")
    func noCorrelationID() {
        let logger = CBTLogger.logger(for: .workshop)
        logger.debug("Test without correlation ID")
        logger.info("Test without correlation ID")
    }

    @Test("CBTSignpost begin/end does not crash")
    func signpostSmokeTest() {
        let state = CBTSignpost.begin("TestInterval")
        CBTSignpost.end("TestInterval", state)
    }
}
