import Foundation

/// A minimal protocol for "if this returns" — generated when a protocol is completed.
public struct RelapsePreventionCard: Codable, Sendable, Equatable {
    public var keyTrigger: String
    public var updatedBelief: String
    public var bestInterventionID: String
    public var bestInterventionTitle: String
    public var summaryNote: String

    public init(
        keyTrigger: String,
        updatedBelief: String,
        bestInterventionID: String,
        bestInterventionTitle: String,
        summaryNote: String
    ) {
        self.keyTrigger = keyTrigger
        self.updatedBelief = updatedBelief
        self.bestInterventionID = bestInterventionID
        self.bestInterventionTitle = bestInterventionTitle
        self.summaryNote = summaryNote
    }
}
