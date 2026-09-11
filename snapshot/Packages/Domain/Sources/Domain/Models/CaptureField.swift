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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        fieldType = try container.decode(CaptureFieldType.self, forKey: .fieldType)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
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
