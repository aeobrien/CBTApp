import SwiftUI
import Domain

/// Onboarding screen 1: Welcome and "What is CBT?"
///
/// Introduces the app's purpose with a calm, approachable tone.
struct OnboardingWelcomeView: View {
    let viewModel: OnboardingFlowViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)

                VStack(spacing: 12) {
                    Text("Welcome to CBT")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your personal toolkit for understanding\nand changing unhelpful thinking patterns.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        icon: "lightbulb.fill",
                        title: "What is CBT?",
                        description: "Cognitive Behavioural Therapy helps you notice the links between thoughts, feelings, and actions — then test whether those thoughts are accurate."
                    )

                    InfoRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Patterns, not problems",
                        description: "We all have thinking patterns that sometimes get stuck. CBT gives you structured ways to unstick them."
                    )

                    InfoRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Evidence-based",
                        description: "This app uses techniques backed by decades of clinical research, adapted for self-guided use."
                    )
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
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

                Button("Skip introduction") {
                    viewModel.skip()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.bar)
        }
        .navigationBarBackButtonHidden()
    }
}

/// A horizontal row with an icon, title, and description.
private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingWelcomeView(viewModel: OnboardingFlowViewModel(onComplete: {}))
    }
}
