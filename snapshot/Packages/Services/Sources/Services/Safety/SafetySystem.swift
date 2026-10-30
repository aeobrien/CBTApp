import Foundation
import Domain
import Utilities

/// Concrete implementation of SafetySystemProtocol.
///
/// Composes static classifiers and detectors to provide a unified safety API for ViewModels.
public final class SafetySystem: SafetySystemProtocol, @unchecked Sendable {

    private let logger: ModuleLogger

    public nonisolated init(logger: ModuleLogger = CBTLogger.logger(for: .safety)) {
        self.logger = logger
    }

    public func scanText(_ text: String) -> SafetyAlert? {
        let level = AcuteRiskClassifier.classify(text)
        let alert = AcuteRiskClassifier.alert(for: level)
        if alert != nil {
            logger.info("[Safety] Acute risk detected in text (level: \(level))")
        }
        return alert
    }

    public func evaluateChronicNonResponse(scores: [MeasureScore]) -> SafetyAlert? {
        let alert = EscalationEvaluator.evaluate(scores: scores)
        if let alert {
            logger.info("[Safety] Escalation detected: \(alert.kind.rawValue)")
        }
        return alert
    }

    public func evaluateDisengagement(runs: [Run], relativeTo now: Date) -> SafetyAlert? {
        let alert = DisengagementDetector.evaluate(runs: runs, relativeTo: now)
        if alert != nil {
            logger.info("[Safety] Disengagement detected")
        }
        return alert
    }

    public func evaluateCompulsiveUse(runs: [Run]) -> SafetyAlert? {
        let alert = CompulsiveUseDetector.evaluate(runs: runs)
        if let alert {
            logger.info("[Safety] Compulsive use detected: \(alert.message)")
        }
        return alert
    }
}
