import Foundation

/// A structured behavioural experiment within a protocol.
public struct Experiment: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var prediction: String
    public var steps: [String]
    public var measures: [String]
    public var successCriteria: String
    public var outcomes: [ExperimentOutcome]

    public init(
        id: UUID = UUID(),
        prediction: String,
        steps: [String],
        measures: [String],
        successCriteria: String,
        outcomes: [ExperimentOutcome] = []
    ) {
        self.id = id
        self.prediction = prediction
        self.steps = steps
        self.measures = measures
        self.successCriteria = successCriteria
        self.outcomes = outcomes
    }
}

/// A recorded outcome of running an experiment.
public struct ExperimentOutcome: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    public var result: String
    public var predictionAccurate: Bool?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        result: String,
        predictionAccurate: Bool? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.result = result
        self.predictionAccurate = predictionAccurate
        self.notes = notes
    }
}
