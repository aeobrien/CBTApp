import Foundation

/// Defines a single field shown during Run capture (Screen B).
/// Fields are rendered in the order they appear in the protocol's capture_fields array.
public struct CaptureField: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var fieldType: CaptureFieldType
    public var label: String
    public var isRequired: Bool

    public init(
        id: UUID = UUID(),
        fieldType: CaptureFieldType,
        label: String,
        isRequired: Bool = false
    ) {
        self.id = id
        self.fieldType = fieldType
        self.label = label
        self.isRequired = isRequired
    }
}

/// The type of input a capture field expects.
public enum CaptureFieldType: String, Codable, Sendable, CaseIterable, Identifiable {
    case situationText = "situation_text"
    case hotThoughtPicker = "hot_thought_picker"
    case emotionPicker = "emotion_picker"
    case bodySignalPicker = "body_signal_picker"
    case urgePicker = "urge_picker"
    case slider
    case beliefStrength = "belief_strength"

    public var id: String { rawValue }
}
