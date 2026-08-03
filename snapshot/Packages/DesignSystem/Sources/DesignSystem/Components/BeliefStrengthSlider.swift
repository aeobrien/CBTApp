import SwiftUI

/// Specialised slider for rating belief strength (0–100%).
///
/// Adds contextual labels at low/mid/high ranges to help users
/// calibrate their rating against a clinical scale.
public struct BeliefStrengthSlider: View {
    let label: String
    @Binding var value: Double

    public init(label: String = "How strongly do you believe this?", value: Binding<Double>) {
        self.label = label
        self._value = value
    }

    private var intensityLabel: String {
        switch value {
        case 0..<20: "Not at all"
        case 20..<40: "A little"
        case 40..<60: "Moderately"
        case 60..<80: "Strongly"
        default: "Very strongly"
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            Text(label)
                .font(CBTTypography.bodySecondary)

            HStack {
                Text("\(Int(value))%")
                    .font(CBTTypography.sliderValue)
                    .foregroundStyle(CBTColors.accent)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: value)
                Spacer()
                Text(intensityLabel)
                    .font(CBTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $value, in: 0...100, step: 1)
                .tint(CBTColors.sliderFill)

            HStack {
                Text("0%")
                Spacer()
                Text("100%")
            }
            .font(CBTTypography.detail)
            .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value)) percent, \(intensityLabel)")
    }
}

#Preview {
    VStack(spacing: 32) {
        BeliefStrengthSlider(value: .constant(15))
        BeliefStrengthSlider(value: .constant(50))
        BeliefStrengthSlider(value: .constant(85))
    }
    .padding()
}
