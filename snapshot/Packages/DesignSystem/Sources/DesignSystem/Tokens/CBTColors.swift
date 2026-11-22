import SwiftUI

/// Semantic colour tokens for the CBT app.
///
/// Uses SwiftUI's adaptive colours so light/dark mode is automatic.
/// No gamification colours (gold, confetti, etc.) — clinical and calm.
public enum CBTColors {

    // MARK: - Accent

    /// Main accent — calm teal.
    public static let accent = Color(red: 0.25, green: 0.60, blue: 0.65)
    /// Secondary accent — softer complement.
    public static let accentSecondary = Color(red: 0.45, green: 0.55, blue: 0.75)

    // MARK: - Semantic

    /// Positive outcome / improvement indicator.
    public static let positive = Color.green.opacity(0.85)
    /// Warning / attention needed.
    public static let warning = Color.orange.opacity(0.85)
    /// Negative outcome / cost indicator.
    public static let negative = Color.red.opacity(0.8)
    /// Neutral / informational.
    public static let info = Color.blue.opacity(0.8)

    // MARK: - Component-specific

    /// Chip selected background.
    public static let chipSelected = accent.opacity(0.15)
    /// Chip unselected border.
    public static let chipBorder = Color.gray.opacity(0.3)
    /// Safety banner background.
    public static let safetyBackground = Color.blue.opacity(0.08)
    /// Slider track.
    public static let sliderTrack = Color.gray.opacity(0.25)
    /// Slider filled portion.
    public static let sliderFill = accent
}
