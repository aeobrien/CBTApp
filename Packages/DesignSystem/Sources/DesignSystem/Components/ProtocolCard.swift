import SwiftUI

/// Card displaying a protocol suggestion.
///
/// Shows protocol name, summary, status badge, and optional
/// last-used date. Used in protocol selection lists.
public struct ProtocolCard: View {
    let name: String
    let summary: String
    let statusLabel: String
    let lastUsed: String?

    public init(name: String, summary: String, statusLabel: String, lastUsed: String? = nil) {
        self.name = name
        self.summary = summary
        self.statusLabel = statusLabel
        self.lastUsed = lastUsed
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            HStack {
                Text(name)
                    .font(CBTTypography.cardTitle)
                Spacer()
                Text(statusLabel)
                    .font(CBTTypography.detail)
                    .padding(.horizontal, CBTSpacing.xs)
                    .padding(.vertical, CBTSpacing.xxs)
                    .background(
                        Capsule().fill(CBTColors.accent.opacity(0.12))
                    )
                    .foregroundStyle(CBTColors.accent)
            }

            Text(summary)
                .font(CBTTypography.bodySecondary)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if let lastUsed {
                Text("Last used: \(lastUsed)")
                    .font(CBTTypography.detail)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(CBTSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        ProtocolCard(
            name: "Late-Night Rumination",
            summary: "For when you're lying in bed replaying conversations and worrying about the future.",
            statusLabel: "Active",
            lastUsed: "2 days ago"
        )
        ProtocolCard(
            name: "Work Perfectionism",
            summary: "Targeting the belief that work must be flawless to be acceptable.",
            statusLabel: "Paused"
        )
    }
    .padding()
}
