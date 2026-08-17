import SwiftUI
import Domain
import DesignSystem

/// Stage 9: Generate the CBT protocol from workshop data.
struct Stage9GenerationView: View {
    @Bindable var viewModel: WorkshopFlowViewModel
    var onComplete: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            switch viewModel.generationState {
            case .idle:
                idleContent

            case .generating:
                generatingContent

            case .success(let proto):
                successContent(proto: proto)

            case .failed(let message):
                failedContent(message: message)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Generate")
        .navigationBarBackButtonHidden(
            { if case .success = viewModel.generationState { return true } else { return false } }()
        )
    }

    // MARK: - Idle

    private var idleContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(CBTColors.accent)

            Text("Ready to generate your protocol")
                .font(.title3)
                .fontWeight(.medium)

            Text("The agent will use everything from your workshop to create a personalised CBT protocol.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.generateProtocol() }
            } label: {
                Label(
                    viewModel.isRevisionMode ? "Revise Protocol" : "Generate Protocol",
                    systemImage: "sparkles"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(CBTColors.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Generating

    private var generatingContent: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()

            Text("Generating your protocol...")
                .font(.headline)

            Text("This may take a moment. The agent is building and validating your protocol.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Success

    private func successContent(proto: CBTProtocol) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(CBTColors.positive)

            Text("Protocol Created")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("Name", value: proto.name)
                LabeledContent("Summary", value: proto.summary)
                LabeledContent("Interventions", value: "\(proto.interventions.count)")
                LabeledContent("Experiments", value: "\(proto.experiments.count)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                onComplete?()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(CBTColors.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Failed

    private func failedContent(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(CBTColors.negative)

            Text("Generation Failed")
                .font(.title3)
                .fontWeight(.medium)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.generateProtocol() }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(CBTColors.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview("Idle") {
    NavigationStack {
        Stage9GenerationView(viewModel: WorkshopFlowViewModel(
            agentService: MockAgentService(),
            protocolRepository: MockProtocolRepository()
        ))
    }
}
