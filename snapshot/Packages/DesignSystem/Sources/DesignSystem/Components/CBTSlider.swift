import SwiftUI

/// A large, thumb-friendly slider for 0–100 ratings.
///
/// Used for emotion intensity, belief strength, and urge ratings.
/// Shows the current value prominently above the slider.
public struct CBTSlider: View {
    let label: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...100
    var step: Double = 1
    var showValue: Bool = true

    public init(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        showValue: Bool = true
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.showValue = showValue
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            HStack {
                Text(label)
                    .font(CBTTypography.bodySecondary)
                Spacer()
                if showValue {
                    Text("\(Int(value))")
                        .font(CBTTypography.sliderValue)
                        .foregroundStyle(CBTColors.accent)
                        .contentTransition(.numericText())
                        .animation(.snappy(duration: 0.15), value: value)
                }
            }

            Slider(value: $value, in: range, step: step)
                .tint(CBTColors.sliderFill)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value))")
    }
}

#Preview {
    VStack(spacing: 24) {
        CBTSlider(label: "Anxiety Intensity", value: .constant(65))
        CBTSlider(label: "Belief Strength", value: .constant(30))
        CBTSlider(label: "Urge to Avoid", value: .constant(80))
    }
    .padding()
}
