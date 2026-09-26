import Foundation

/// In-memory mock implementation of ProtocolRepositoryProtocol for testing and previews.
public actor MockProtocolRepository: ProtocolRepositoryProtocol {
    public var protocols: [UUID: CBTProtocol]

    public init(protocols: [CBTProtocol] = []) {
        self.protocols = Dictionary(uniqueKeysWithValues: protocols.map { ($0.id, $0) })
    }

    public func fetchAll(status: ProtocolStatus?) async throws -> [CBTProtocol] {
        let all = Array(protocols.values)
        if let status {
            return all.filter { $0.status == status }.sorted { $0.updatedAt > $1.updatedAt }
        }
        return all.sorted { $0.updatedAt > $1.updatedAt }
    }

    public func fetch(id: UUID) async throws -> CBTProtocol? {
        protocols[id]
    }

    public func search(query: String) async throws -> [CBTProtocol] {
        let lowered = query.lowercased()
        return Array(protocols.values).filter {
            $0.name.lowercased().contains(lowered) ||
            $0.whenToUse.contains { $0.lowercased().contains(lowered) } ||
            $0.hotThoughtTemplates.contains { $0.lowercased().contains(lowered) }
        }
    }

    public func save(_ cbtProtocol: CBTProtocol) async throws {
        protocols[cbtProtocol.id] = cbtProtocol
    }

    public func delete(id: UUID) async throws {
        protocols.removeValue(forKey: id)
    }

    public func count(status: ProtocolStatus?) async throws -> Int {
        if let status {
            return protocols.values.filter { $0.status == status }.count
        }
        return protocols.count
    }
}
