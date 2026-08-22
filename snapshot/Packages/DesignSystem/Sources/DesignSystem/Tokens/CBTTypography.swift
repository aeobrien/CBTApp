import SwiftUI

/// Typography tokens using iOS Dynamic Type scale.
///
/// All styles use Apple's built-in text styles so they scale
/// automatically with the user's accessibility settings.
public enum CBTTypography {

    // MARK: - Headings

    /// Screen title (e.g. "Run Mode", "Workshop").
    public static let screenTitle = Font.largeTitle.weight(.bold)
    /// Section heading within a screen.
    public static let sectionTitle = Font.title3.weight(.semibold)
    /// Card or item title.
    public static let cardTitle = Font.headline

    // MARK: - Body

    /// Primary body text.
    public static let body = Font.body
    /// Secondary descriptive text.
    public static let bodySecondary = Font.subheadline
    /// Script / instruction text (slightly larger for readability).
    public static let script = Font.body.leading(.loose)

    // MARK: - Detail

    /// Caption text (metadata, timestamps).
    public static let caption = Font.caption
    /// Smallest text (timer labels, chip badges).
    public static let detail = Font.caption2

    // MARK: - Specialised

    /// Hot thought text — italic body.
    public static let hotThought = Font.body.italic()
    /// Slider value label.
    public static let sliderValue = Font.title2.weight(.medium).monospacedDigit()
    /// Timer display.
    public static let timer = Font.system(size: 48, weight: .light, design: .rounded).monospacedDigit()
}
