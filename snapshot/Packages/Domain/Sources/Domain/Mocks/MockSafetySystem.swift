import Foundation

/// Configurable mock for SafetySystemProtocol, for testing and previews.
public final class MockSafetySystem: SafetySystemProtocol, @unchecked Sendable {

    // MARK: - Configuration

    public var scanTextResult: SafetyAlert?
    public var chronicNonResponseResult: SafetyAlert?
    public var disengagementResult: SafetyAlert?
    public var compulsiveUseResult: SafetyAlert?

    // MARK: - Call tracking

    public private(set) var scanTextCallCount = 0
    public private(set) var lastScannedText: String?
    public private(set) var chronicNonResponseCallCount = 0
    public private(set) var disengagementCallCount = 0
    public private(set) var compulsiveUseCallCount = 0

    // MARK: - Init

    public init(
        scanTextResult: SafetyAlert? = nil,
        chronicNonResponseResult: SafetyAlert? = nil,
        disengagementResult: SafetyAlert? = nil,
        compulsiveUseResult: SafetyAlert? = nil
    ) {
        self.scanTextResult = scanTextResult
        self.chronicNonResponseResult = chronicNonResponseResult
        self.disengagementResult = disengagementResult
        self.compulsiveUseResult = compulsiveUseResult
    }

    // MARK: - SafetySystemProtocol

    public func scanText(_ text: String) -> SafetyAlert? {
        scanTextCallCount += 1
        lastScannedText = text
        return scanTextResult
    }

    public func evaluateChronicNonResponse(scores: [MeasureScore]) -> SafetyAlert? {
        chronicNonResponseCallCount += 1
        return chronicNonResponseResult
    }

    public func evaluateDisengagement(runs: [Run], relativeTo now: Date) -> SafetyAlert? {
        disengagementCallCount += 1
        return disengagementResult
    }

    public func evaluateCompulsiveUse(runs: [Run]) -> SafetyAlert? {
        compulsiveUseCallCount += 1
        return compulsiveUseResult
    }
}
