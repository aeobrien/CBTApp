import Foundation

/// Fixed list of emotions available for selection during Run capture.
public enum EmotionType: String, Codable, Sendable, CaseIterable, Identifiable {
    case anxiety
    case sadness
    case anger
    case frustration
    case shame
    case guilt
    case fear
    case disgust
    case hopelessness
    case loneliness
    case overwhelm
    case irritability
    case dread
    case embarrassment
    case jealousy
    case emptiness

    public var id: String { rawValue }

    public var displayName: String {
        rawValue.capitalized
    }
}
