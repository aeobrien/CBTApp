import Foundation

/// A curated, evidence-based intervention template from the library.
/// The agent selects and parameterises these; it does not invent new types.
public struct InterventionTemplate: Codable, Sendable, Equatable, Identifiable {
    public var id: String
    public var type: InterventionType
    public var name: String
    public var indication: String
    public var contraindications: [String]
    public var steps: [String]
    public var exampleScripts: [String]
    public var durationEstimate: Int
    public var successCriteria: String
    public var evidenceBasis: String

    public init(
        id: String,
        type: InterventionType,
        name: String,
        indication: String,
        contraindications: [String] = [],
        steps: [String] = [],
        exampleScripts: [String] = [],
        durationEstimate: Int,
        successCriteria: String,
        evidenceBasis: String
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.indication = indication
        self.contraindications = contraindications
        self.steps = steps
        self.exampleScripts = exampleScripts
        self.durationEstimate = durationEstimate
        self.successCriteria = successCriteria
        self.evidenceBasis = evidenceBasis
    }
}
