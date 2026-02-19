import SwiftUI
import Domain
import DesignSystem

/// Screen A: Choose which protocol to run.
struct ProtocolSelectionView: View {
    @Bindable var viewModel: RunFlowViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CBTSpacing.md) {
                // Search
                TextField("Search protocols...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
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
    }
}

#Preview {
    NavigationStack {
        ProtocolSelectionView(viewModel: .preview())
    }
}
