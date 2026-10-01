import Foundation

/// Safety copy and resource links attached to a protocol.
public struct SafetyInfo: Codable, Sendable, Equatable {
    public var message: String
    public var resources: [SafetyResource]

    public init(
        message: String = "If you're in crisis or need immediate support, please reach out.",
        resources: [SafetyResource] = SafetyResource.ukDefaults
    ) {
        self.message = message
        self.resources = resources
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? "If you're in crisis or need immediate support, please reach out."
        resources = try container.decodeIfPresent([SafetyResource].self, forKey: .resources) ?? SafetyResource.ukDefaults
    }
}

/// A single safety resource link.
public struct SafetyResource: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var detail: String
    public var phoneNumber: String?
    public var url: String?

    public init(
        id: UUID = UUID(),
        name: String,
        detail: String,
        phoneNumber: String? = nil,
        url: String? = nil
    ) {
        self.id = id
        self.name = name
        self.detail = detail
        self.phoneNumber = phoneNumber
        self.url = url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }

    /// Default UK crisis resources.
    public static let ukDefaults: [SafetyResource] = [
        SafetyResource(
            name: "Samaritans",
            detail: "Available 24/7, free to call",
            phoneNumber: "116 123",
            url: "https://www.samaritans.org"
        ),
        SafetyResource(
            name: "Crisis Text Line",
            detail: "Text SHOUT to 85258",
            phoneNumber: nil,
            url: "https://www.giveusashout.org"
        ),
        SafetyResource(
            name: "NHS Talking Therapies",
            detail: "Self-refer for talking therapy",
            phoneNumber: nil,
            url: "https://www.nhs.uk/mental-health/talking-therapies-medicine-treatments/talking-therapies-and-counselling/nhs-talking-therapies/"
        )
    ]
}
