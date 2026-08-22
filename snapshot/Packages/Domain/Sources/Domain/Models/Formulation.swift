import Foundation

/// A linked model of the maintaining cycle: trigger → appraisal → emotion → behaviour.
/// Built progressively during Workshop Stages 1–4.
public struct Formulation: Codable, Sendable, Equatable {
    public var triggerAppraisalLinks: [TriggerAppraisalLink]
    public var maintainingCycles: [MaintainingCycle]

    public init(
        triggerAppraisalLinks: [TriggerAppraisalLink] = [],
        maintainingCycles: [MaintainingCycle] = []
    ) {
        self.triggerAppraisalLinks = triggerAppraisalLinks
        self.maintainingCycles = maintainingCycles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        triggerAppraisalLinks = try container.decodeIfPresent([TriggerAppraisalLink].self, forKey: .triggerAppraisalLinks) ?? []
        maintainingCycles = try container.decodeIfPresent([MaintainingCycle].self, forKey: .maintainingCycles) ?? []
    }
}

/// Maps a trigger through the cognitive chain.
public struct TriggerAppraisalLink: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var trigger: String
    public var appraisal: String
    public var emotion: EmotionType
    public var behaviour: UrgeType

    public init(
        id: UUID = UUID(),
        trigger: String,
        appraisal: String,
        emotion: EmotionType,
        behaviour: UrgeType
    ) {
        self.id = id
        self.trigger = trigger
        self.appraisal = appraisal
        self.emotion = emotion
        self.behaviour = behaviour
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        trigger = try container.decode(String.self, forKey: .trigger)
        appraisal = try container.decode(String.self, forKey: .appraisal)
        emotion = try container.decode(EmotionType.self, forKey: .emotion)
        behaviour = try container.decode(UrgeType.self, forKey: .behaviour)
    }
}

/// A single maintaining cycle with its function and cost.
public struct MaintainingCycle: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var behaviour: MaintainingBehaviourType
    public var shortTermFunction: String
    public var longTermCost: String
    public var targetInterventionID: String?

    public init(
        id: UUID = UUID(),
        behaviour: MaintainingBehaviourType,
        shortTermFunction: String,
        longTermCost: String,
        targetInterventionID: String? = nil
    ) {
        self.id = id
        self.behaviour = behaviour
        self.shortTermFunction = shortTermFunction
        self.longTermCost = longTermCost
        self.targetInterventionID = targetInterventionID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        behaviour = try container.decode(MaintainingBehaviourType.self, forKey: .behaviour)
        shortTermFunction = try container.decodeIfPresent(String.self, forKey: .shortTermFunction) ?? ""
        longTermCost = try container.decodeIfPresent(String.self, forKey: .longTermCost) ?? ""
        targetInterventionID = try container.decodeIfPresent(String.self, forKey: .targetInterventionID)
    }
}
