import Foundation
import SwiftData
import Domain
import Data
import Services
import Utilities

/// Holds all service instances, created once at app launch.
@MainActor
struct DependencyContainer {
    let modelContainer: ModelContainer
    let protocolRepository: any ProtocolRepositoryProtocol
    let runRepository: any RunRepositoryProtocol
    let measureRepository: any MeasureRepositoryProtocol
    let agentService: any AgentServiceProtocol
    let safetySystem: any SafetySystemProtocol
    let voiceInputService: any VoiceInputServiceProtocol

    private static let logger = CBTLogger.logger(for: .app)

    /// Production initializer — on-disk SwiftData, real services.
    init() {
        Self.logger.info("Initialising DependencyContainer with production services")

        do {
            self.modelContainer = try DataContainer.makeContainer()
        } catch {
            Self.logger.error("Failed to create ModelContainer: \(error.localizedDescription)")
            fatalError("Failed to create ModelContainer: \(error)")
        }

        self.protocolRepository = SwiftDataProtocolRepository(modelContainer: modelContainer)
        self.runRepository = SwiftDataRunRepository(modelContainer: modelContainer)
        self.measureRepository = SwiftDataMeasureRepository(modelContainer: modelContainer)
        self.agentService = OpenAIAgentService(apiClient: OpenAIAPIClient())
        self.safetySystem = SafetySystem()
        self.voiceInputService = WhisperVoiceInputService()
    }

    /// Preview/test initializer — in-memory SwiftData, mock services.
    private init(inMemory: Bool) {
        Self.logger.info("Initialising DependencyContainer with in-memory mocks")

        do {
            self.modelContainer = try DataContainer.makeInMemoryContainer()
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }

        self.protocolRepository = MockProtocolRepository(protocols: SampleData.allProtocols)
        self.runRepository = MockRunRepository()
        self.measureRepository = MockMeasureRepository()
        self.agentService = MockAgentService()
        self.safetySystem = MockSafetySystem()
        self.voiceInputService = MockVoiceInputService()
    }

    /// Factory for previews and tests.
    static func makePreview() -> DependencyContainer {
        DependencyContainer(inMemory: true)
    }

    /// Seeds sample protocols into SwiftData if the store is empty.
    func seedSampleDataIfNeeded() async {
        do {
            let count = try await protocolRepository.count(status: nil)
            if count == 0 {
                Self.logger.info("Empty store detected — seeding \(SampleData.allProtocols.count) sample protocols")
                for proto in SampleData.allProtocols {
                    try await protocolRepository.save(proto)
                }
                Self.logger.info("Sample data seeded successfully")
            }
        } catch {
            Self.logger.error("Failed to seed sample data: \(error.localizedDescription)")
        }
    }

    /// Prepares the Whisper voice model in the background.
    func prepareVoiceModel() async {
        do {
            try await voiceInputService.prepareModel()
            Self.logger.info("Whisper model prepared successfully")
        } catch {
            Self.logger.error("Failed to prepare Whisper model: \(error.localizedDescription)")
        }
    }
}
