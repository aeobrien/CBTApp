import Foundation

/// A parameterised intervention selected from the curated library.
public struct InterventionInstance: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    /// Reference to the curated library template.
    public var interventionID: String
    public var type: InterventionType
    public var title: String
    /// The parameterised script (≤ 240 characters).
    public var script: String
    /// Ordered steps if this is a checklist-style intervention.
    public var steps: [String]
    /// Estimated duration in seconds.
    public var durationEstimate: Int
    /// Whether this intervention uses a timer.
    public var isTimed: Bool

    public init(
        id: UUID = UUID(),
        interventionID: String,
        type: InterventionType,
        title: String,
        script: String,
        steps: [String] = [],
        durationEstimate: Int,
        isTimed: Bool = false
    ) {
        self.id = id
        self.interventionID = interventionID
        self.type = type
        self.title = title
        self.script = script
        self.steps = steps
        self.durationEstimate = durationEstimate
        self.isTimed = isTimed
    }
}
