import Foundation
@preconcurrency import SwiftData

/// Provides a configured SwiftData ModelContainer for the app.
public enum DataContainer {
    /// The schema for all persisted models.
    public static nonisolated(unsafe) let schema = Schema([
        PersistedProtocol.self,
        PersistedRun.self,
        PersistedMeasureScore.self
    ])

    /// Create a container for production use (on-disk storage).
    public static func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Create an in-memory container for testing and previews.
    public static func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
