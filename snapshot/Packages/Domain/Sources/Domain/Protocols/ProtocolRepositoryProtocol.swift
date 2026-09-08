import Foundation

/// Repository for CRUD operations on CBT protocols.
public protocol ProtocolRepositoryProtocol: Sendable {
    /// Fetch all protocols, optionally filtered by status.
    func fetchAll(status: ProtocolStatus?) async throws -> [CBTProtocol]

    /// Fetch a single protocol by ID.
    func fetch(id: UUID) async throws -> CBTProtocol?

    /// Search protocols by name or trigger text.
    func search(query: String) async throws -> [CBTProtocol]

    /// Save a new protocol or update an existing one.
    func save(_ protocol: CBTProtocol) async throws

    /// Delete a protocol by ID.
    func delete(id: UUID) async throws

    /// Count protocols, optionally filtered by status.
    func count(status: ProtocolStatus?) async throws -> Int
}
