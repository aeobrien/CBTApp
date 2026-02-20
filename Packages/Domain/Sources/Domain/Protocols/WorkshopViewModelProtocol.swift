import Foundation

/// The state of protocol generation in Stage 9.
public enum GenerationState: Sendable, Equatable {
    case idle
    case generating
    case success(CBTProtocol)
    case failed(String)

    public static func == (lhs: GenerationState, rhs: GenerationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): true
        case (.generating, .generating): true
        case (.success(let a), .success(let b)): a.id == b.id
        case (.failed(let a), .failed(let b)): a == b
        default: false
        }
    }
}

/// Testable protocol for the workshop flow ViewModel.
@MainActor
public protocol WorkshopFlowViewModelProtocol: AnyObject {

    // MARK: - Navigation

    var currentStage: WorkshopStage { get }
    var navigationPath: [WorkshopStage] { get set }
    func advance() async
    func goBack()

    // MARK: - Stage 1: Capture

    var situation: String { get set }
    var hotThought: String { get set }
    var selectedEmotion: EmotionType? { get set }
    var emotionIntensity: Int { get set }
    var selectedUrge: UrgeType? { get set }

    // MARK: - Guided Discovery (Stages 2, 3, 4, 6)

    var conversationMessages: [ConversationMessage] { get }
    var userInput: String { get set }
    var isAgentTyping: Bool { get }
    func sendMessage() async

    // MARK: - Stage 5: Interventions

    var availableInterventions: [InterventionTemplate] { get }
    var selectedInterventions: [InterventionTemplate] { get }
    func selectIntervention(_ template: InterventionTemplate)
    func deselectIntervention(_ template: InterventionTemplate)

    // MARK: - Stage 7: Capture Fields

    var captureFields: [CaptureField] { get set }

    // MARK: - Stage 7.5: Measures

    var selectedMeasures: [StandardisedMeasure] { get set }

    // MARK: - Stage 8: Review Rules

    var reviewRules: [ReviewRule] { get set }

    // MARK: - Stage 9: Generation

    var generationState: GenerationState { get }
    func generateProtocol() async

    // MARK: - Formulation

    var formulation: Formulation { get }

    // MARK: - Revision mode

    var isRevisionMode: Bool { get }
}
