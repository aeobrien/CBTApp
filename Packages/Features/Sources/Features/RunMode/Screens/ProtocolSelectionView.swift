import SwiftUI
import Domain
import DesignSystem

/// Screen A: Choose which protocol to run.
struct ProtocolSelectionView: View {
    @Bindable var viewModel: RunFlowViewModel
    @State private var showingTriage = false

    var body: some View {
        ScrollView {
            VStack(spacing: CBTSpacing.md) {
                // Search
                TextField("Search protocols...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, CBTSpacing.md)

                // Quick Triage button
                Button {
                    showingTriage = true
                } label: {
                    Label("I'm not sure", systemImage: "questionmark.circle")
                        .font(CBTTypography.body)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(CBTColors.accent)
                .padding(.horizontal, CBTSpacing.md)

                if viewModel.filteredProtocols.isEmpty {
                    ContentUnavailableView(
                        "No protocols found",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Create a protocol in the Workshop to get started.")
                    )
                    .padding(.top, CBTSpacing.xl)
                } else {
                    LazyVStack(spacing: CBTSpacing.sm) {
                        ForEach(viewModel.filteredProtocols) { proto in
                            Button {
                                Task {
                                    await viewModel.selectProtocol(proto)
                                }
                            } label: {
                                ProtocolCard(
                                    name: proto.name,
                                    summary: proto.summary,
                                    statusLabel: proto.status.displayName
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, CBTSpacing.md)
                }
            }
            .padding(.vertical, CBTSpacing.md)
        }
        .navigationTitle("Choose Protocol")
        .task {
            await viewModel.loadProtocols()
        }
        .sheet(isPresented: $showingTriage) {
            QuickTriageView(
                viewModel: QuickTriageViewModel(
                    protocols: viewModel.allProtocols,
                    onSelectProtocol: { [viewModel] proto in
                        Task { await viewModel.selectProtocol(proto) }
                    }
                )
            )
        }
    }
}

#Preview {
    NavigationStack {
        ProtocolSelectionView(viewModel: .preview())
    }
}
