import SwiftUI

/// Spacing and layout tokens.
///
/// Uses a 4pt base grid for consistent spacing throughout the app.
public enum CBTSpacing {

    // MARK: - Base grid

    /// 4pt — minimal spacing (e.g. between icon and label).
    public static let xxs: CGFloat = 4
    /// 8pt — tight spacing (e.g. within a chip).
    public static let xs: CGFloat = 8
    /// 12pt — compact spacing.
    public static let sm: CGFloat = 12
    /// 16pt — standard spacing (default padding).
    public static let md: CGFloat = 16
    /// 24pt — generous spacing (between sections).
    public static let lg: CGFloat = 24
    /// 32pt — large spacing (screen margins, major separators).
    public static let xl: CGFloat = 32
    /// 48pt — extra large (hero spacing).
    public static let xxl: CGFloat = 48

    // MARK: - Component-specific

    /// Corner radius for cards and containers.
    public static let cardRadius: CGFloat = 12
    /// Corner radius for chips and small elements.
    public static let chipRadius: CGFloat = 8
    /// Corner radius for buttons.
    public static let buttonRadius: CGFloat = 10
    /// Minimum touch target size (Apple HIG: 44pt).
    public static let minTouchTarget: CGFloat = 44
    /// Slider thumb size.
    public static let sliderThumb: CGFloat = 28
}
