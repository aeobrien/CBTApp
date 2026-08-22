import Foundation
import Domain
import Utilities

/// Drives the measure administration questionnaire flow.
@Observable
@MainActor
public final class MeasureAdminViewModel: MeasureAdminViewModelProtocol {

    // MARK: - Dependencies

    private let measureRepository: any MeasureRepositoryProtocol
    private let logger: ModuleLogger

    // MARK: - Published state

    public let definition: MeasureDefinition
    public var currentItemIndex: Int = 0
    public var responses: [Int] = []
    public var isComplete: Bool = false
    public var previousScore: MeasureScore?

    // MARK: - Computed

    public var totalScore: Int {
        responses.reduce(0, +)
    }

    public var scoringBand: ScoringBand? {
        definition.band(for: totalScore)
    }

    // MARK: - Init

    public nonisolated init(
        definition: MeasureDefinition,
        measureRepository: any MeasureRepositoryProtocol,
        logger: ModuleLogger = CBTLogger.logger(for: .evidence)
    ) {
        self.definition = definition
        self.measureRepository = measureRepository
        self.logger = logger
    }

    // MARK: - Actions

    /// Load previous score for comparison on result screen.
    public func loadPreviousScore() async {
        do {
            previousScore = try await measureRepository.latestScore(measureID: definition.rawValue)
            logger.debug("Previous \(definition.rawValue) score: \(previousScore?.totalScore ?? -1)")
        } catch {
            logger.error("Failed to load previous score: \(error.localizedDescription)")
        }
    }

    public func selectResponse(_ value: Int) {
        if currentItemIndex < responses.count {
            responses[currentItemIndex] = value
        } else {
            responses.append(value)
        }
        logger.debug("Response for item \(currentItemIndex): \(value)")
    }

    public func advance() {
        guard currentItemIndex < definition.items.count - 1 else {
            isComplete = true
            logger.info("\(definition.rawValue) complete — score: \(totalScore), band: \(scoringBand?.label ?? "unknown")")
            return
        }
        currentItemIndex += 1
    }

    public func goBack() {
        guard currentItemIndex > 0 else { return }
        currentItemIndex -= 1
    }

    public func submit() async {
        let score = MeasureScore(
            totalScore: totalScore,
            itemResponses: responses
        )
        do {
            try await measureRepository.saveScore(score, measureID: definition.rawValue)
            logger.info("\(definition.rawValue) score saved: \(totalScore)")
        } catch {
            logger.error("Failed to save \(definition.rawValue) score: \(error.localizedDescription)")
        }
    }
}
