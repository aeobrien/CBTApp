import SwiftUI

/// A tappable chip with selection state.
///
/// Used for EmotionChip, UrgeChip, BodySignalChip, ContextChip —
/// any multi-select tag picker. The chip adapts its appearance
/// based on selection state.
public struct SelectableChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    public init(label: String, isSelected: Bool, action: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(CBTTypography.bodySecondary)
                .padding(.horizontal, CBTSpacing.sm)
                .padding(.vertical, CBTSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: CBTSpacing.chipRadius)
                        .fill(isSelected ? CBTColors.chipSelected : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CBTSpacing.chipRadius)
                        .strokeBorder(
                            isSelected ? CBTColors.accent : CBTColors.chipBorder,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
                .foregroundStyle(isSelected ? CBTColors.accent : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(label)
    }
}

/// A flow layout grid of selectable chips.
///
/// Wraps chips to new lines as needed. Use with any array of
/// identifiable/hashable items that have a display name.
public struct ChipGrid<Item: Hashable>: View {
    let items: [Item]
    let labelForItem: (Item) -> String
    @Binding var selection: Set<Item>

    public init(
        items: [Item],
        labelForItem: @escaping (Item) -> String,
        selection: Binding<Set<Item>>
    ) {
        self.items = items
        self.labelForItem = labelForItem
        self._selection = selection
    }

    public var body: some View {
        FlowLayout(spacing: CBTSpacing.xs) {
            ForEach(items, id: \.self) { item in
                SelectableChip(
                    label: labelForItem(item),
                    isSelected: selection.contains(item)
                ) {
                    if selection.contains(item) {
                        selection.remove(item)
                    } else {
                        selection.insert(item)
                    }
                }
            }
        }
    }
}

/// Simple flow layout that wraps children to new lines.
public struct FlowLayout: Layout {
    var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (index, row) in rows.enumerated() {
            let rowHeight = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight
            if index < rows.count - 1 { height += spacing }
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
            var x = bounds.minX
            for index in row {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Int]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[Int]] = [[]]
        var currentRowWidth: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentRowWidth = 0
            }
            rows[rows.count - 1].append(index)
            currentRowWidth += size.width + spacing
        }
        return rows
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SelectableChip(label: "Anxiety", isSelected: true) {}
        SelectableChip(label: "Sadness", isSelected: false) {}

        ChipGrid(
            items: ["Anxiety", "Sadness", "Anger", "Frustration", "Shame", "Guilt", "Fear"],
            labelForItem: { $0 },
            selection: .constant(Set(["Anxiety", "Shame"]))
        )
    }
    .padding()
}
