import Foundation

/// The core protocol object — a reusable CBT plan.
///
/// Conforms to the Protocol JSON spec (v1) defined in the Technical Brief.
/// This is a Domain-layer value type. SwiftData persistence is handled
/// by a separate `@Model` class in the Data layer.
public struct CBTProtocol: Codable, Sendable, Equatable, Identifiable {

    // MARK: - Required fields

    public var id: UUID
    public var version: String
    public var name: String
    public var summary: String
    public var status: ProtocolStatus
    public var whenToUse: [String]
    public var hotThoughtTemplates: [String]
    public var maintainingBehaviours: [MaintainingBehaviour]
    public var targets: ProtocolTargets
    public var captureFields: [CaptureField]
    public var interventions: [InterventionInstance]
    public var experiments: [Experiment]
    public var measures: [String]
    public var reviewRules: [ReviewRule]
    public var safety: SafetyInfo
    public var formulation: Formulation

    // MARK: - Optional fields

    public var tags: [String]
    public var exclusions: [String]
    public var tone: String?
    public var defaults: ProtocolDefaults?
    public var standardisedMeasures: [StandardisedMeasure]
    public var escalationRules: [EscalationRule]
    public var completionSummary: String?
    public var relapsePreventionCard: RelapsePreventionCard?

    // MARK: - Metadata

    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        version: String = "1.0.0",
        name: String,
        summary: String,
        status: ProtocolStatus = .active,
        whenToUse: [String] = [],
        hotThoughtTemplates: [String] = [],
        maintainingBehaviours: [MaintainingBehaviour] = [],
        targets: ProtocolTargets = ProtocolTargets(),
        captureFields: [CaptureField] = CaptureField.defaultFields,
        interventions: [InterventionInstance] = [],
        experiments: [Experiment] = [],
        measures: [String] = ["emotion", "belief_strength"],
        reviewRules: [ReviewRule] = ReviewRule.defaults,
        safety: SafetyInfo = SafetyInfo(),
        formulation: Formulation = Formulation(),
        tags: [String] = [],
        exclusions: [String] = [],
        tone: String? = "neutral",
        defaults: ProtocolDefaults? = nil,
        standardisedMeasures: [StandardisedMeasure] = [],
        escalationRules: [EscalationRule] = [],
        completionSummary: String? = nil,
        relapsePreventionCard: RelapsePreventionCard? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.version = version
        self.name = name
        self.summary = summary
        self.status = status
        self.whenToUse = whenToUse
        self.hotThoughtTemplates = hotThoughtTemplates
        self.maintainingBehaviours = maintainingBehaviours
        self.targets = targets
        self.captureFields = captureFields
        self.interventions = interventions
        self.experiments = experiments
        self.measures = measures
        self.reviewRules = reviewRules
        self.safety = safety
        self.formulation = formulation
        self.tags = tags
        self.exclusions = exclusions
        self.tone = tone
        self.defaults = defaults
        self.standardisedMeasures = standardisedMeasures
        self.escalationRules = escalationRules
        self.completionSummary = completionSummary
        self.relapsePreventionCard = relapsePreventionCard
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Custom Decodable

    /// Lenient decoder that defaults missing optional/array fields.
    /// Required because LLM-generated JSON often omits optional arrays.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required fields
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0.0"
        name = try container.decode(String.self, forKey: .name)
        summary = try container.decode(String.self, forKey: .summary)
        status = try container.decodeIfPresent(ProtocolStatus.self, forKey: .status) ?? .active
        whenToUse = try container.decodeIfPresent([String].self, forKey: .whenToUse) ?? []
        hotThoughtTemplates = try container.decodeIfPresent([String].self, forKey: .hotThoughtTemplates) ?? []
        maintainingBehaviours = try container.decodeIfPresent([MaintainingBehaviour].self, forKey: .maintainingBehaviours) ?? []
        targets = try container.decodeIfPresent(ProtocolTargets.self, forKey: .targets) ?? ProtocolTargets()
        captureFields = try container.decodeIfPresent([CaptureField].self, forKey: .captureFields) ?? CaptureField.defaultFields
        interventions = try container.decodeIfPresent([InterventionInstance].self, forKey: .interventions) ?? []
        experiments = try container.decodeIfPresent([Experiment].self, forKey: .experiments) ?? []
        measures = try container.decodeIfPresent([String].self, forKey: .measures) ?? ["emotion", "belief_strength"]
        reviewRules = try container.decodeIfPresent([ReviewRule].self, forKey: .reviewRules) ?? ReviewRule.defaults
        safety = try container.decodeIfPresent(SafetyInfo.self, forKey: .safety) ?? SafetyInfo()
        formulation = try container.decodeIfPresent(Formulation.self, forKey: .formulation) ?? Formulation()

        // Optional fields — always lenient
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        exclusions = try container.decodeIfPresent([String].self, forKey: .exclusions) ?? []
        tone = try container.decodeIfPresent(String.self, forKey: .tone)
        defaults = try container.decodeIfPresent(ProtocolDefaults.self, forKey: .defaults)
        standardisedMeasures = try container.decodeIfPresent([StandardisedMeasure].self, forKey: .standardisedMeasures) ?? []
        escalationRules = try container.decodeIfPresent([EscalationRule].self, forKey: .escalationRules) ?? []
        completionSummary = try container.decodeIfPresent(String.self, forKey: .completionSummary)
        relapsePreventionCard = try container.decodeIfPresent(RelapsePreventionCard.self, forKey: .relapsePreventionCard)

        // Metadata — default to now if missing
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}

// MARK: - Supporting types

/// A maintaining behaviour with its function and cost.
public struct MaintainingBehaviour: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var type: MaintainingBehaviourType
    public var description: String
    public var shortTermRelief: String
    public var longTermCost: String

    public init(
        id: UUID = UUID(),
        type: MaintainingBehaviourType,
        description: String = "",
        shortTermRelief: String = "",
        longTermCost: String = ""
    ) {
        self.id = id
        self.type = type
        self.description = description
        self.shortTermRelief = shortTermRelief
        self.longTermCost = longTermCost
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        type = try container.decode(MaintainingBehaviourType.self, forKey: .type)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        shortTermRelief = try container.decodeIfPresent(String.self, forKey: .shortTermRelief) ?? ""
        longTermCost = try container.decodeIfPresent(String.self, forKey: .longTermCost) ?? ""
    }
}

/// The target belief and loop for a protocol.
public struct ProtocolTargets: Codable, Sendable, Equatable {
    public var targetBelief: String
    public var targetLoop: TargetLoopType?

    public init(
        targetBelief: String = "",
        targetLoop: TargetLoopType? = nil
    ) {
        self.targetBelief = targetBelief
        self.targetLoop = targetLoop
    }
}

/// Default values for a protocol.
public struct ProtocolDefaults: Codable, Sendable, Equatable {
    public var defaultEmotionIntensity: Int?
    public var defaultBeliefStrength: Int?
    public var recommendedInterventionID: String?

    public init(
        defaultEmotionIntensity: Int? = nil,
        defaultBeliefStrength: Int? = nil,
        recommendedInterventionID: String? = nil
    ) {
        self.defaultEmotionIntensity = defaultEmotionIntensity
        self.defaultBeliefStrength = defaultBeliefStrength
        self.recommendedInterventionID = recommendedInterventionID
    }
}

// MARK: - Default values

extension CaptureField {
    /// The standard set of capture fields for a new protocol.
    public static let defaultFields: [CaptureField] = [
        CaptureField(fieldType: .situationText, label: "What's happening?"),
        CaptureField(fieldType: .hotThoughtPicker, label: "Hot thought"),
        CaptureField(fieldType: .emotionPicker, label: "Emotion", isRequired: true),
        CaptureField(fieldType: .bodySignalPicker, label: "Body signals"),
        CaptureField(fieldType: .urgePicker, label: "Urge"),
    ]
}

extension ReviewRule {
    /// Default review rules for new protocols.
    public static let defaults: [ReviewRule] = [
        ReviewRule(condition: "after_5_runs", action: "prompt_review"),
        ReviewRule(condition: "no_shift_after_3_runs", action: "revise_scripts_experiment"),
    ]
}
