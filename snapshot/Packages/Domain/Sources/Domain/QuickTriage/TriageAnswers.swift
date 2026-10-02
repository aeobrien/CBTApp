import Foundation

/// Captured answers from the Quick Triage wizard.
public struct TriageAnswers: Sendable, Equatable {
    public var urge: UrgeType
    public var theme: TriageTheme
    public var intensity: Int

    public init(urge: UrgeType, theme: TriageTheme, intensity: Int) {
        self.urge = urge
        self.theme = theme
        self.intensity = max(0, min(100, intensity))
    }
}
