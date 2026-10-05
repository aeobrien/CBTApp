import SwiftUI
import Domain

/// Onboarding screen 2: "What's a hot thought?"
///
/// Shows 3 tappable examples demonstrating the situation → thought → emotion chain.
struct OnboardingHotThoughtsView: View {
    let viewModel: OnboardingFlowViewModel
    @State private var revealedExamples: Set<Int> = []

    private let examples: [(situation: String, thought: String, emotion: String)] = [
        (
            situation: "About to present at a meeting",
            thought: "\"I'm going to mess this up\"",
            emotion: "Anxiety"
        ),
        (
            situation: "Friend didn't reply to a message",
            thought: "\"They don't care about me\"",
            emotion: "Sadness"
        ),
        (
            situation: "Made an error at work",
            thought: "\"I always get things wrong\"",
            emotion: "Shame"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hot Thoughts")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("A \"hot thought\" is the one thought that carries the most emotional charge in a moment. It's not always obvious — tap each example to see the chain.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(Array(examples.enumerated()), id: \.offset) { index, example in
                    ExampleCard(
                        situation: example.situation,
                        thought: example.thought,
                        emotion: example.emotion,
                        isRevealed: revealedExamples.contains(index)
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if revealedExamples.contains(index) {
                                revealedExamples.remove(index)
                            } else {
                                revealedExamples.insert(index)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why does this matter?")
                        .font(.headline)

                    Text("Hot thoughts drive your emotions and behaviour. By catching them, you create a chance to respond differently.")
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

/// An interactive card showing the situation → thought → emotion chain.
private struct ExampleCard: View {
    let situation: String
    let thought: String
    let emotion: String
    let isRevealed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.tint)
                    Text(situation)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: isRevealed ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }

                if isRevealed {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "thought.bubble.fill")
                                .foregroundStyle(.orange)
                            Text(thought)
                                .font(.subheadline)
                                .italic()
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                            Text(emotion)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .background(.gray.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        OnboardingHotThoughtsView(viewModel: OnboardingFlowViewModel(onComplete: {}))
    }
}
