import SwiftUI
import Domain
import Features
import Services

struct SafetyTestView: View {
    @State private var textInput = ""
    @State private var scanResult: String = ""
    @State private var pendingAlert: SafetyAlert?

    private let safetySystem = SafetySystem()

    var body: some View {
        List {
            Section("Text Scanning") {
                TextField("Enter text to scan...", text: $textInput, axis: .vertical)
                    .lineLimit(3...6)

                Button("Scan Text") {
                    if let alert = safetySystem.scanText(textInput) {
                        scanResult = "[\(alert.kind.rawValue)] \(alert.message) (canContinue: \(alert.canContinue))"
                        pendingAlert = alert
                    } else {
                        scanResult = "No risk detected"
                    }
                }
                .disabled(textInput.isEmpty)

                Text(scanResult)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Quick Test Phrases") {
                Button("Acute: \"I want to kill myself\"") {
                    textInput = "I want to kill myself"
                }
                Button("Acute: \"I'm suicidal\"") {
                    textInput = "I'm suicidal"
                }
                Button("Elevated: \"I'd be better off dead\"") {
                    textInput = "I'd be better off dead"
                }
                Button("Elevated: \"There's no hope\"") {
                    textInput = "There's no hope"
                }
                Button("Benign: \"I'm anxious about my exam\"") {
                    textInput = "I'm anxious about my exam"
                }
                Button("Metaphor: \"I could kill for a coffee\"") {
                    textInput = "I could kill for a coffee"
                }
            }

            Section("PHQ-9 Escalation") {
                Button("Test: Score increase +5") {
                    let scores = [
                        MeasureScore(date: Date().addingTimeInterval(-86400 * 14), totalScore: 10),
                        MeasureScore(date: Date(), totalScore: 15)
                    ]
                    if let alert = safetySystem.evaluateChronicNonResponse(scores: scores) {
                        pendingAlert = alert
                        scanResult = "[\(alert.kind.rawValue)] \(alert.message)"
                    } else {
                        scanResult = "No escalation detected"
                    }
                }

                Button("Test: Item 9 suicidality") {
                    let items = [0, 1, 2, 1, 0, 1, 1, 0, 2]
                    let scores = [
                        MeasureScore(date: Date().addingTimeInterval(-86400 * 14), totalScore: 8),
                        MeasureScore(date: Date(), totalScore: 8, itemResponses: items)
                    ]
                    if let alert = safetySystem.evaluateChronicNonResponse(scores: scores) {
                        pendingAlert = alert
                        scanResult = "[\(alert.kind.rawValue)] \(alert.message)"
                    } else {
                        scanResult = "No escalation detected"
                    }
                }
            }

            Section("Disengagement") {
                Button("Test: 20-day gap") {
                    let runs = [
                        Run(
                            protocolID: UUID(),
                            timestampStart: Date().addingTimeInterval(-86400 * 20),
                            timestampEnd: Date().addingTimeInterval(-86400 * 20 + 180),
                            completionStatus: .completed
                        )
                    ]
                    if let alert = safetySystem.evaluateDisengagement(runs: runs, relativeTo: Date()) {
                        pendingAlert = alert
                        scanResult = "[\(alert.kind.rawValue)] \(alert.message)"
                    } else {
                        scanResult = "No disengagement detected"
                    }
                }
            }

            Section("Safety Resources View") {
                Button("Show Acute Alert") {
                    pendingAlert = SafetyAlert(
                        kind: .acuteRisk,
                        message: "It sounds like you may be in crisis. Please reach out to one of the support services below.",
                        canContinue: false
                    )
                }
                Button("Show Elevated Alert") {
                    pendingAlert = SafetyAlert(
                        kind: .acuteRisk,
                        message: "It sounds like you're going through a difficult time. Support is available.",
                        canContinue: true
                    )
                }
                Button("Show Disengagement Alert") {
                    pendingAlert = SafetyAlert(
                        kind: .disengagement,
                        message: "You haven't completed a run in 20 days. That's okay — pick up where you left off.",
                        canContinue: true
                    )
                }
            }
        }
        .navigationTitle("Safety Test Harness")
        .safetyCover(alert: $pendingAlert)
    }
}

#Preview {
    NavigationStack {
        SafetyTestView()
    }
}
