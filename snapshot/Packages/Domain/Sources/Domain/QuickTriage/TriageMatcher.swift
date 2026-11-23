import Foundation

/// Matches triage answers to existing protocols by scoring relevance.
public enum TriageMatcher {

    /// A protocol matched with a relevance score.
    public struct ScoredMatch: Sendable, Equatable {
        public let cbtProtocol: CBTProtocol
        public let score: Int

        public init(cbtProtocol: CBTProtocol, score: Int) {
            self.cbtProtocol = cbtProtocol
            self.score = score
        }
    }

    /// Map from TargetLoopType to the TriageTheme it most closely represents.
    private static let loopToTheme: [TargetLoopType: TriageTheme] = [
        .rumination: .loss,
        .avoidance: .fearOfFailure,
        .checking: .uncertainty,
        .reassurance: .uncertainty,
        .perfectionism: .perfectionism,
        .socialComparison: .comparison,
        .catastrophising: .fearOfFailure,
        .selfCriticism: .socialThreat,
    ]

    /// Map from UrgeType to the MaintainingBehaviourType it corresponds to.
    private static let urgeToMaintaining: [UrgeType: MaintainingBehaviourType] = [
        .ruminate: .rumination,
        .check: .checking,
        .avoid: .avoidance,
        .scroll: .scrolling,
        .overwork: .overworking,
        .argue: .arguingInternally,
        .reassuranceSeek: .reassuranceSeeking,
        .withdraw: .withdrawal,
        .selfCriticise: .rumination,
    ]

    /// Score and rank protocols against the user's triage answers.
    /// Returns matches sorted descending by score, excluding zero-score protocols.
    public static func match(answers: TriageAnswers, protocols: [CBTProtocol]) -> [ScoredMatch] {
        let themeKeywords = themeKeywordMap[answers.theme] ?? []

        let scored: [ScoredMatch] = protocols.compactMap { proto in
            var score = 0

            // +2 if protocol's targetLoop maps to the chosen theme
            if let loop = proto.targets.targetLoop,
               loopToTheme[loop] == answers.theme {
                score += 2
            }

            // +1 per matching tag keyword
            let lowerTags = proto.tags.map { $0.lowercased() }
            for keyword in themeKeywords {
                if lowerTags.contains(where: { $0.contains(keyword) }) {
                    score += 1
                }
            }

            // +1 if any maintaining behaviour type maps to the chosen urge
            if let maintainingType = urgeToMaintaining[answers.urge] {
                if proto.maintainingBehaviours.contains(where: { $0.type == maintainingType }) {
                    score += 1
                }
            }

            guard score > 0 else { return nil }
            return ScoredMatch(cbtProtocol: proto, score: score)
        }

        return scored.sorted { $0.score > $1.score }
    }

    /// Keywords associated with each triage theme for tag matching.
    private static let themeKeywordMap: [TriageTheme: [String]] = [
        .loss: ["loss", "grief", "sadness", "rumination"],
        .comparison: ["comparison", "social", "jealousy", "envy"],
        .fearOfFailure: ["failure", "avoidance", "catastroph", "fear"],
        .perfectionism: ["perfect", "standard", "control"],
        .socialThreat: ["social", "rejection", "judgment", "criticism"],
        .uncertainty: ["uncertainty", "checking", "reassurance", "doubt"],
    ]
}
