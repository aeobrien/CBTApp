import SwiftUI
import Domain

/// Multi-select tag group for outcome tags at the end of a run.
///
/// Wraps `ChipGrid` with `OutcomeTag` values from the Domain layer.
public struct OutcomeTagSelector: View {
    @Binding var selection: Set<OutcomeTag>

    public init(selection: Binding<Set<OutcomeTag>>) {
        self._selection = selection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.xs) {
            Text("What did you notice?")
                .font(CBTTypography.bodySecondary)

            ChipGrid(
                items: OutcomeTag.allCases.map { $0 },
                labelForItem: { $0.displayName },
                selection: $selection
            )
        }
    }
}

#Preview {
    OutcomeTagSelector(selection: .constant(Set([.uncomfortableButTolerable])))
        .padding()
}
