import SwiftUI
import Domain
import DesignSystem

/// Horizontal progress indicator showing all workshop stages.
///
/// Current stage is highlighted, completed stages are filled,
/// future stages appear dim.
struct StageProgressBar: View {
    let current: WorkshopStage

    private var currentIndex: Int {
        WorkshopStage.allCases.firstIndex(of: current) ?? 0
    }

    private var stages: [(offset: Int, element: WorkshopStage)] {
        Array(WorkshopStage.allCases.enumerated())
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(stages, id: \.element) { item in
                let index = item.offset
                let stage = item.element

                VStack(spacing: 2) {
                    Circle()
                        .fill(fillColor(for: index))
                        .frame(width: 10, height: 10)
                        .overlay {
                            if index == currentIndex {
                                Circle()
                                    .stroke(CBTColors.accent, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }

                    Text(stage.stageNumber)
                        .font(.system(size: 8))
                        .foregroundStyle(index <= currentIndex ? .primary : .tertiary)
                }

                if index < WorkshopStage.allCases.count - 1 {
                    Rectangle()
                        .fill(index < currentIndex ? CBTColors.accent : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private func fillColor(for index: Int) -> Color {
        if index <= currentIndex {
            return CBTColors.accent
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StageProgressBar(current: .capture)
        StageProgressBar(current: .maintaining)
        StageProgressBar(current: .interventionSelection)
        StageProgressBar(current: .generation)
    }
    .padding()
}
