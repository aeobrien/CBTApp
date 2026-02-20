import SwiftUI
import Domain
import Features

/// Test harness for Workshop Mode using MockAgentService.
struct WorkshopTestView: View {
    @State private var showingWorkshop = false
    @State private var showingRevision = false

    var body: some View {
        List {
            Section("New Protocol") {
                Button {
                    showingWorkshop = true
                } label: {
                    Label("Start Workshop", systemImage: "hammer.fill")
                }
            }

            Section("Revision Mode") {
                Button {
                    showingRevision = true
                } label: {
                    Label("Revise Sample Protocol", systemImage: "pencil.circle.fill")
                }
            }

            Section("About") {
                Text("Workshop Mode uses MockAgentService with contextual responses. The agent gives stage-appropriate canned replies to simulate guided discovery.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Workshop Test")
        .fullScreenCover(isPresented: $showingWorkshop) {
            WorkshopFlowCoordinator(
                agentService: Self.contextualMock(),
                protocolRepository: MockProtocolRepository()
            )
        }
        .fullScreenCover(isPresented: $showingRevision) {
            WorkshopFlowCoordinator(
                agentService: Self.contextualMock(),
                protocolRepository: MockProtocolRepository(),
                existingProtocol: SampleData.allProtocols.first
            )
        }
    }

    private static func contextualMock() -> MockAgentService {
        let mock = MockAgentService()
        mock.useContextualResponses = true
        return mock
    }
}

#Preview {
    NavigationStack {
        WorkshopTestView()
    }
}
