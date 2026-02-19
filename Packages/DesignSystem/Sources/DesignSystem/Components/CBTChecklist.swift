import SwiftUI

/// A simple checklist with tappable checkboxes (max ~5 items).
///
/// Used for intervention steps, experiment steps, or review checklists.
public struct CBTChecklist: View {
    let items: [String]
    @Binding var checkedIndices: Set<Int>

    public init(items: [String], checkedIndices: Binding<Set<Int>>) {
        self.items = items
        self._checkedIndices = checkedIndices
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button {
                    if checkedIndices.contains(index) {
                        checkedIndices.remove(index)
                    } else {
                        checkedIndices.insert(index)
                    }
                } label: {
                    HStack(alignment: .top, spacing: CBTSpacing.sm) {
                        Image(systemName: checkedIndices.contains(index)
                              ? "checkmark.circle.fill"
                              : "circle")
                            .foregroundStyle(
                                checkedIndices.contains(index)
                                ? CBTColors.accent
                                : .secondary
                            )
                            .font(.title3)

                        Text(item)
                            .font(CBTTypography.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .strikethrough(checkedIndices.contains(index))
                    }
                    .frame(minHeight: CBTSpacing.minTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(checkedIndices.contains(index) ? .isSelected : [])
            }
        }
    }
}

#Preview {
    CBTChecklist(
        items: [
            "Notice the thought",
            "Label it as a thought",
            "Let it pass without engaging",
            "Return attention to breath"
        ],
        checkedIndices: .constant(Set([0, 1]))
    )
    .padding()
}
