import Foundation

/// The kind of safety concern detected.
public enum SafetyAlertKind: String, Sendable, Equatable {
    case acuteRisk = "acute_risk"
    case chronicNonResponse = "chronic_non_response"
    case disengagement = "disengagement"
    case compulsiveUse = "compulsive_use"
}

/// A safety alert raised by the safety system.
public struct SafetyAlert: Sendable, Equatable, Identifiable {
    public var id: String { kind.rawValue }
    public var kind: SafetyAlertKind
    public var message: String
    public var resources: [SafetyResource]
    /// When false (acute risk), the user cannot dismiss and continue.
    public var canContinue: Bool

    public init(
        kind: SafetyAlertKind,
        message: String,
        resources: [SafetyResource] = SafetyResource.ukDefaults,
        canContinue: Bool
    ) {
        self.kind = kind
        self.message = message
        self.resources = resources
        self.canContinue = canContinue
    }
}
