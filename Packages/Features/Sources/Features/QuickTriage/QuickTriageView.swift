import SwiftUI
import Domain
import DesignSystem

/// Quick Triage wizard — helps users find the right protocol when unsure.
struct QuickTriageView: View {
    @Bindable var viewModel: QuickTriageViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CBTSpacing.lg) {
                // Progress indicator
                HStack(spacing: CBTSpacing.xs) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= viewModel.step ? CBTColors.accent : CBTColors.sliderTrack)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, CBTSpacing.md)

                // Step content
                ScrollView {
                    VStack(spacing: CBTSpacing.lg) {
                        switch viewModel.step {
                        case 0: urgeStep
                        case 1: themeStep
                        case 2: intensityStep
                        case 3: resultStep
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, CBTSpacing.md)
                }

                // Navigation buttons
                if viewModel.step < 3 {
                    HStack(spacing: CBTSpacing.md) {
                        if viewModel.step > 0 {
                            Button("Back") {
                                viewModel.goBack()
                            }
                            .buttonStyle(.bordered)
                        }

                        Spacer()

                        Button("Next") {
                            viewModel.advance()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CBTColors.accent)
                        .disabled(!viewModel.canAdvance)
                    }
                    .padding(.horizontal, CBTSpacing.md)
                    .padding(.bottom, CBTSpacing.md)
                }
            }
            .navigationTitle("Quick Triage")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step Views

    private var urgeStep: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.md) {
            Text("What's the strongest urge right now?")
                .font(CBTTypography.sectionTitle)

            FlowLayout {
                ForEach(UrgeType.allCases) { urge in
                    SelectableChip(
                        label: urge.displayName,
                        isSelected: viewModel.selectedUrge == urge
                    ) {
                        viewModel.selectedUrge = urge
                    }
                }
            }
        }
    }

    private var themeStep: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.md) {
            Text("What best describes the theme?")
                .font(CBTTypography.sectionTitle)

            FlowLayout {
                ForEach(TriageTheme.allCases) { theme in
                    SelectableChip(
                        label: theme.displayName,
                        isSelected: viewModel.selectedTheme == theme
                    ) {
                        viewModel.selectedTheme = theme
                    }
                }
            }
        }
    }

    private var intensityStep: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.md) {
            Text("How intense is it?")
                .font(CBTTypography.sectionTitle)

            CBTSlider(label: "Intensity", value: $viewModel.intensity)
        }
    }

    private var resultStep: some View {
        VStack(alignment: .leading, spacing: CBTSpacing.md) {
            if viewModel.matches.isEmpty {
                ContentUnavailableView(
                    "No matching protocols",
                    systemImage: "magnifyingglass",
                    description: Text("Try building a new protocol in the Workshop.")
                )

                Button("Build New Protocol") {
                    viewModel.buildNew()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(CBTColors.accent)
            } else {
                Text("We found \(viewModel.matches.count) matching protocol\(viewModel.matches.count == 1 ? "" : "s")")
                    .font(CBTTypography.sectionTitle)

                ForEach(viewModel.matches, id: \.cbtProtocol.id) { match in
                    Button {
                        viewModel.selectMatch(match)
                        dismiss()
                    } label: {
                        ProtocolCard(
                            name: match.cbtProtocol.name,
                            summary: match.cbtProtocol.summary,
                            statusLabel: "Score: \(match.score)"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button("Build something new instead") {
                    viewModel.buildNew()
                    dismiss()
                }
                .font(CBTTypography.bodySecondary)
                .padding(.top, CBTSpacing.sm)
            }
        }
    }
}

#Preview {
    QuickTriageView(viewModel: .preview())
}
