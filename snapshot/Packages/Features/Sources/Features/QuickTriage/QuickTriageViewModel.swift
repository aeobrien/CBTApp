import Foundation
import Domain
import Utilities

/// Drives the Quick Triage wizard: 4 steps to match the user to a protocol.
@Observable
@MainActor
public final class QuickTriageViewModel {

    // MARK: - Callbacks

    nonisolated(unsafe) private var onSelectProtocol: ((CBTProtocol) -> Void)?
    nonisolated(unsafe) private var onBuildNew: (() -> Void)?

    // MARK: - Dependencies

    private let protocols: [CBTProtocol]
    private let logger: ModuleLogger

    // MARK: - State

    /// Current step: 0=urge, 1=theme, 2=intensity, 3=result
    public var step: Int = 0
    public var selectedUrge: UrgeType?
    public var selectedTheme: TriageTheme?
    public var intensity: Double = 50
    public var matches: [TriageMatcher.ScoredMatch] = []

    // MARK: - Init

    public nonisolated init(
        protocols: [CBTProtocol],
        onSelectProtocol: ((CBTProtocol) -> Void)? = nil,
        onBuildNew: (() -> Void)? = nil,
        logger: ModuleLogger = CBTLogger.logger(for: .quickTriage)
    ) {
        self.protocols = protocols
        self.onSelectProtocol = onSelectProtocol
        self.onBuildNew = onBuildNew
        self.logger = logger
    }

    // MARK: - Navigation

    public func advance() {
        guard step < 3 else { return }

        if step == 2 {
            // Moving to results — run matching
            runMatching()
        }
        step += 1
        logger.debug("Triage advanced to step \(step)")
    }

    public func goBack() {
        guard step > 0 else { return }
        step -= 1
        logger.debug("Triage went back to step \(step)")
    }

    public var canAdvance: Bool {
        switch step {
        case 0: return selectedUrge != nil
        case 1: return selectedTheme != nil
        case 2: return true
        default: return false
        }
    }

    // MARK: - Actions

    public func selectMatch(_ match: TriageMatcher.ScoredMatch) {
        logger.info("Triage selected protocol: \(match.cbtProtocol.name) (score: \(match.score))")
        onSelectProtocol?(match.cbtProtocol)
    }

    public func buildNew() {
        logger.info("Triage chose to build new protocol")
        onBuildNew?()
    }

    // MARK: - Matching

    private func runMatching() {
        guard let urge = selectedUrge, let theme = selectedTheme else { return }
        let answers = TriageAnswers(urge: urge, theme: theme, intensity: Int(intensity))
        matches = TriageMatcher.match(answers: answers, protocols: protocols)
        logger.info("Triage matched \(matches.count) protocols for theme=\(theme.displayName), urge=\(urge.displayName)")
    }

    // MARK: - Preview

    public static func preview() -> QuickTriageViewModel {
        QuickTriageViewModel(protocols: SampleData.allProtocols)
    }
}
