import Foundation
import SwiftData
import Domain

/// SwiftData model for persisting CBTProtocol.
///
/// Stores the Domain-layer CBTProtocol as encoded JSON data.
/// This avoids deeply nested @Model hierarchies and keeps
/// the persistence layer as a thin storage wrapper.
@Model
public final class PersistedProtocol {

    public var protocolID: UUID
    public var name: String
    public var summary: String
    public var statusRaw: String
    public var version: String
    public var createdAt: Date
    public var updatedAt: Date

    /// The full CBTProtocol encoded as JSON.
    public var protocolData: Data

    /// Searchable fields for query support.
    public var searchableText: String
    public var tags: [String]

    public init(from cbtProtocol: CBTProtocol) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.protocolData = try encoder.encode(cbtProtocol)
        self.protocolID = cbtProtocol.id
        self.name = cbtProtocol.name
        self.summary = cbtProtocol.summary
        self.statusRaw = cbtProtocol.status.rawValue
        self.version = cbtProtocol.version
        self.createdAt = cbtProtocol.createdAt
        self.updatedAt = cbtProtocol.updatedAt
        self.tags = cbtProtocol.tags

        // Build searchable text from name, triggers, and hot thoughts
        var searchParts = [cbtProtocol.name, cbtProtocol.summary]
        searchParts.append(contentsOf: cbtProtocol.whenToUse)
        searchParts.append(contentsOf: cbtProtocol.hotThoughtTemplates)
        self.searchableText = searchParts.joined(separator: " ").lowercased()
    }

    /// Convert back to the Domain-layer type.
    public func toDomain() throws -> CBTProtocol {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CBTProtocol.self, from: protocolData)
    }

    /// Update from a Domain-layer type.
    public func update(from cbtProtocol: CBTProtocol) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.protocolData = try encoder.encode(cbtProtocol)
        self.protocolID = cbtProtocol.id
        self.name = cbtProtocol.name
        self.summary = cbtProtocol.summary
        self.statusRaw = cbtProtocol.status.rawValue
        self.version = cbtProtocol.version
        self.updatedAt = cbtProtocol.updatedAt
        self.tags = cbtProtocol.tags

        var searchParts = [cbtProtocol.name, cbtProtocol.summary]
        searchParts.append(contentsOf: cbtProtocol.whenToUse)
        searchParts.append(contentsOf: cbtProtocol.hotThoughtTemplates)
        self.searchableText = searchParts.joined(separator: " ").lowercased()
    }
}
