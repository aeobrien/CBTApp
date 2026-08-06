import SwiftUI
import Domain

/// Onboarding screen 4: "Why we test, not argue"
///
/// Explains the behavioural experiment approach with a mini example
/// showing prediction → test → discover.
struct OnboardingTestingView: View {
    let viewModel: OnboardingFlowViewModel
    @State private var experimentStep: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Testing Beliefs")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("CBT doesn't ask you to think positively or argue with your thoughts. Instead, you design small experiments to test whether they're accurate.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                // Mini experiment walkthrough
                VStack(alignment: .leading, spacing: 16) {
                    Text("A mini experiment")
                        .font(.headline)

                    ExperimentStep(
                        step: 1,
                        title: "Predict",
                        description: "\"If I speak up in the meeting, everyone will think I'm stupid.\"",
                        icon: "questionmark.circle.fill",
                        color: .orange,
                        isVisible: experimentStep >= 0
                    )

                    ExperimentStep(
                        step: 2,
                        title: "Test",
                        description: "Make one comment in tomorrow's meeting. Notice what actually happens.",
                        icon: "flask.fill",
                        color: .blue,
                        isVisible: experimentStep >= 1
                    )

                    ExperimentStep(
                        step: 3,
                        title: "Discover",
                        description: "\"Two people nodded. Nobody looked confused. The prediction was wrong.\"",
                        icon: "lightbulb.fill",
                        color: .green,
                        isVisible: experimentStep >= 2
                    )
                }
                .padding()
                .background(.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if experimentStep < 2 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            experimentStep += 1
                        }
                    } label: {
                        Label("Reveal next step", systemImage: "arrow.down.circle")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why experiments work")
                        .font(.headline)

                    Text("Your brain trusts experience more than logic. When you discover that a feared outcome didn't happen, the belief weakens naturally — no argument needed.")
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

/// A single step in the mini experiment walkthrough.
private struct ExperimentStep: View {
    let step: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(step). \(title)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingTestingView(viewModel: OnboardingFlowViewModel(onComplete: {}))
    }
}
