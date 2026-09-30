import SwiftUI
import Domain

/// Onboarding screen 3: "Patterns that keep you stuck"
///
/// Shows 2 maintaining behaviour examples (rumination, checking) with
/// short-term relief vs long-term cost.
struct OnboardingBehavioursView: View {
    let viewModel: OnboardingFlowViewModel
    @State private var showCosts = false

    private let behaviours: [(name: String, icon: String, relief: String, cost: String)] = [
        (
            name: "Rumination",
            icon: "arrow.triangle.2.circlepath",
            relief: "Feels like problem-solving",
            cost: "Keeps you stuck in the same loop, increases anxiety over time"
        ),
        (
            name: "Checking & reassurance",
            icon: "checkmark.circle",
            relief: "Brief relief from uncertainty",
            cost: "Teaches your brain it can't cope without checking"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Maintaining Behaviours")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Some things we do for relief actually keep the problem going. These are called \"maintaining behaviours\".")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(Array(behaviours.enumerated()), id: \.offset) { _, behaviour in
                    BehaviourCard(
                        name: behaviour.name,
                        icon: behaviour.icon,
                        relief: behaviour.relief,
                        cost: behaviour.cost,
                        showCost: showCosts
                    )
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showCosts.toggle()
                    }
                } label: {
                    Label(
                        showCosts ? "Hide long-term costs" : "Reveal the long-term costs",
                        systemImage: showCosts ? "eye.slash" : "eye"
                    )
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("The key insight")
                        .font(.headline)

                    Text("In CBT, we identify these patterns — not to judge them, but to gently experiment with alternatives.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button {
                    viewModel.advance()
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .background(.bar)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

/// Card showing a maintaining behaviour with optional cost reveal.
private struct BehaviourCard: View {
    let name: String
    let icon: String
    let relief: String
    let cost: String
    let showCost: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.tint)
                    .font(.title3)
                Text(name)
                    .font(.headline)
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Short-term")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(relief)
                        .font(.subheadline)
                }
            }

            if showCost {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Long-term")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(cost)
                            .font(.subheadline)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        OnboardingBehavioursView(viewModel: OnboardingFlowViewModel(onComplete: {}))
    }
}
