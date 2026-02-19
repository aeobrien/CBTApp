import SwiftUI
import Utilities

struct ContentView: View {
    private let logger = CBTLogger.logger(for: .app)

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text("CBT Protocol Builder")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("Phase 0 — Scaffolding Complete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Test Logging") {
                    let correlationID = UUID().uuidString.prefix(8).lowercased()
                    logger.debug("Debug: flow trace test", correlationID: String(correlationID))
                    logger.info("Info: state change test", correlationID: String(correlationID))
                    logger.warning("Warning: recoverable issue test", correlationID: String(correlationID))
                    logger.error("Error: failure test", correlationID: String(correlationID))
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("CBT App")
        }
        .onAppear {
            logger.info("ContentView appeared")
        }
    }
}

#Preview {
    ContentView()
}
