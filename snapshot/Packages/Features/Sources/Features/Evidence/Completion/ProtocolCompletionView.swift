import SwiftUI
import Domain
import DesignSystem

/// Protocol completion flow with learning note and relapse prevention card.
public struct ProtocolCompletionView: View {
    @Bindable var viewModel: ProtocolCompletionViewModel
    var onDismiss: () -> Void

    public init(viewModel: ProtocolCompletionViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CBTSpacing.lg) {
                if viewModel.isCompleted {
                    confirmationView
                } else {
                    completionForm
                }
            }
            .padding(CBTSpacing.md)
        }
        .navigationTitle("Complete Protocol")
    }

    // MARK: - Completion Form

    private var completionForm: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.lg) {
            // Candidate info
            VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                Label("Ready to complete", systemImage: "checkmark.seal")
                    .font(CBTTypography.sectionTitle)
                    .foregroundStyle(.green)
                Text(viewModel.candidate.reason)
                    .font(CBTTypography.detail)
                    .foregroundStyle(.secondary)
            }

            // Learning note
            VStack(alignment: .leading, spacing: CBTSpacing.xs) {
                Text("What did you learn from working through this protocol?")
                    .font(CBTTypography.body)
                TextField("Your key takeaway...", text: $viewModel.learningNote, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }

            // Pre-filled relapse card preview
            VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                Text("Relapse Prevention Card")
                    .font(CBTTypography.sectionTitle)

                if let trigger = viewModel.candidate.suggestedKeyTrigger {
                    LabeledContent("Key trigger", value: trigger)
                        .font(CBTTypography.detail)
                }
                if let belief = viewModel.candidate.suggestedUpdatedBelief {
                    LabeledContent("Target belief", value: belief)
                        .font(CBTTypography.detail)
                }
                if let intervention = viewModel.candidate.suggestedBestInterventionTitle {
                    LabeledContent("Best intervention", value: intervention)
                        .font(CBTTypography.detail)
                }
            }
            .padding(CBTSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            )

            // Complete button
            Button {
                Task { await viewModel.completeProtocol() }
            } label: {
                Label("Complete Protocol", systemImage: "checkmark.seal.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    // MARK: - Confirmation

    private var confirmationView: some View {
        VStack(spacing: CBTSpacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("Protocol Completed")
                .font(CBTTypography.sectionTitle)

            if let card = viewModel.relapseCard {
                VStack(alignment: .leading, spacing: CBTSpacing.sm) {
                    Text("Relapse Prevention Card")
                        .font(CBTTypography.body)
                        .fontWeight(.medium)

                    LabeledContent("Key trigger", value: card.keyTrigger)
                    LabeledContent("Updated belief", value: card.updatedBelief)
                    LabeledContent("Best intervention", value: card.bestInterventionTitle)
                    if !card.summaryNote.isEmpty {
                        LabeledContent("Note", value: card.summaryNote)
                    }
                }
                .font(CBTTypography.detail)
                .padding(CBTSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: CBTSpacing.cardRadius)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
            }

            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
}
