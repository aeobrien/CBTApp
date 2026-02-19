import SwiftUI

/// Unobtrusive banner linking to emergency resources.
///
/// Always visible during runs. Tapping expands to show
/// crisis contact details. Designed to be present but not
/// alarming — consistent with clinical best practice.
public struct SafetyBanner: View {
    @State private var isExpanded = false

    let message: String
    let resources: [(name: String, detail: String)]

    public init(message: String, resources: [(name: String, detail: String)]) {
        self.message = message
        self.resources = resources
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: CBTSpacing.xs) {
                    Image(systemName: "heart.text.square")
                        .foregroundStyle(CBTColors.info)
                    Text("Need support?")
                        .font(CBTTypography.bodySecondary)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(CBTTypography.detail)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(message)
                    .font(CBTTypography.caption)
                    .foregroundStyle(.secondary)

                ForEach(Array(resources.enumerated()), id: \.offset) { _, resource in
                    HStack {
                        Text(resource.name)
                            .font(CBTTypography.bodySecondary)
                            .fontWeight(.medium)
                        Spacer()
                        Text(resource.detail)
                            .font(CBTTypography.bodySecondary)
                            .foregroundStyle(CBTColors.info)
                    }
                }
            }
        }
        .padding(CBTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .fill(CBTColors.safetyBackground)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Safety resources")
    }
}

#Preview {
    SafetyBanner(
        message: "If you're in crisis, please reach out to one of these services.",
        resources: [
            (name: "Samaritans", detail: "116 123"),
            (name: "Crisis Text Line", detail: "Text SHOUT to 85258"),
            (name: "NHS Talking Therapies", detail: "nhs.uk/talk")
        ]
    )
    .padding()
}
