import SwiftUI
import Domain

/// Onboarding screen 5: "Ready to build your first protocol?"
///
/// Final screen with a primary "Start Workshop" button and a
/// secondary "Skip for now" option. Both call `onComplete`.
struct OnboardingReadyView: View {
    let viewModel: OnboardingFlowViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                VStack(spacing: 12) {
                    Text("You're ready")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("You now know the basics of CBT:\nhot thoughts, maintaining behaviours,\nand behavioural experiments.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 16) {
                    SummaryRow(
                        icon: "1.circle.fill",
                        text: "The Workshop will guide you through building a personal protocol"
                    )
                    SummaryRow(
                        icon: "2.circle.fill",
                        text: "Run Mode lets you use your protocol quickly when you need it"
                    )
                    SummaryRow(
                        icon: "3.circle.fill",
                        text: "Over time, you'll gather evidence and refine your approach"
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
                    viewModel.finish()
                } label: {
                    Text("Start Workshop")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Skip for now") {
                    viewModel.skip()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

/// A numbered summary row.
private struct SummaryRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .font(.title3)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingReadyView(viewModel: OnboardingFlowViewModel(onComplete: {}))
    }
}
