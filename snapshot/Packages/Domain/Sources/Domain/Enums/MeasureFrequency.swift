import Foundation

/// How often a standardised measure should be administered.
public enum MeasureFrequency: String, Codable, Sendable, CaseIterable, Identifiable {
    case weekly
    case fortnightly
    case monthly

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }

    /// Number of days between administrations.
    public var intervalDays: Int {
        switch self {
        case .weekly: 7
        case .fortnightly: 14
        case .monthly: 30
        }
    }
}
