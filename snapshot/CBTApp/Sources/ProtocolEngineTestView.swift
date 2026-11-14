import SwiftUI
import Domain

/// Test harness for the Protocol Engine and JITAI logic.
/// Lets you set simulated conditions and see what the engine recommends.
/// Auto-evaluates on every state change for faster testing.
struct ProtocolEngineTestView: View {
    @State private var selectedProtocolIndex = 0
    @State private var capturedIntensity: Double = 50
    @State private var selectedUrge: UrgeType?
    @State private var lastRunHoursAgo: Double = 5
    @State private var lastRunIntensity: Double = 40
    @State private var completedRuns: Double = 3
    @State private var hasDueMeasure = false
    @State private var hasActiveExperiment = false

    @State private var recommendation: String = ""
    @State private var reasoning: String = ""
    @State private var diagnostics: String = ""
    @State private var reviewResults: [ReviewRuleResult] = []

    private let protocols = SampleData.allProtocols

    var body: some View {
        List {
            Section("Protocol") {
                Picker("Protocol", selection: $selectedProtocolIndex) {
                    ForEach(Array(protocols.enumerated()), id: \.offset) { i, proto in
                        Text(proto.name).tag(i)
                    }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.red)
                        Text("Emotion Intensity NOW")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(Int(capturedIntensity))")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                    }
                    Slider(value: $capturedIntensity, in: 0...100, step: 5)
                        .tint(.red)
                    Text(intensityBand(capturedIntensity))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Picker("Urge", selection: $selectedUrge) {
                    Text("None").tag(UrgeType?.none)
                    ForEach(UrgeType.allCases) { urge in
                        Text(urge.displayName).tag(UrgeType?.some(urge))
                    }
                }
            } header: {
                Text("Current Run")
            } footer: {
                Text("What the user just captured in this run")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Last run")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(lastRunHoursAgo))h ago")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $lastRunHoursAgo, in: 0...24, step: 1)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Last run intensity")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(lastRunIntensity))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $lastRunIntensity, in: 0...100, step: 5)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Completed runs")
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(completedRuns))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $completedRuns, in: 0...20, step: 1)
                }

                Toggle("Measure due", isOn: $hasDueMeasure)
                Toggle("Active experiment", isOn: $hasActiveExperiment)
            } header: {
                Text("History")
            } footer: {
                Text("Previous run data and flags")
            }

            if !recommendation.isEmpty {
                Section("Recommendation") {
                    Text(recommendation)
                        .font(.subheadline)
                }

                Section("JITAI Reasoning") {
                    Text(reasoning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Diagnostics") {
                    Text(diagnostics)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }

            Section("Review Rules") {
                Button("Evaluate Review Rules") {
                    evaluateReview()
                }

                if !reviewResults.isEmpty {
                    ForEach(Array(reviewResults.enumerated()), id: \.offset) { _, result in
                        HStack {
                            Image(systemName: result.triggered ? "exclamationmark.triangle.fill" : "checkmark.circle")
                                .foregroundStyle(result.triggered ? .orange : .green)
                            VStack(alignment: .leading) {
                                Text(result.rule.action)
                                    .font(.subheadline)
                                Text(result.reason)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Engine Test Harness")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedProtocolIndex) { evaluate() }
        .onChange(of: capturedIntensity) { evaluate() }
        .onChange(of: selectedUrge) { evaluate() }
        .onChange(of: lastRunHoursAgo) { evaluate() }
        .onChange(of: lastRunIntensity) { evaluate() }
        .onChange(of: completedRuns) { evaluate() }
        .onChange(of: hasDueMeasure) { evaluate() }
        .onChange(of: hasActiveExperiment) { evaluate() }
        .onAppear { evaluate() }
    }

    private func intensityBand(_ value: Double) -> String {
        switch value {
        case 0..<30: return "Low (0-29) → behavioural experiment"
        case 30..<60: return "Moderate (30-59) → standard selection"
        case 60..<80: return "High (60-79) → delay/defusion/opposite"
        default: return "Very high (80+) → delay experiment only"
        }
    }

    private func evaluate() {
        let engine = ProtocolEngine(cbtProtocol: protocols[selectedProtocolIndex])
        let state = JITAIState(
            currentTime: Date(),
            lastRunTime: Date().addingTimeInterval(-lastRunHoursAgo * 3600),
            lastRunIntensity: lastRunIntensity,
            capturedIntensity: capturedIntensity,
            capturedUrge: selectedUrge,
            hasActiveExperiment: hasActiveExperiment,
            hasDueMeasure: hasDueMeasure,
            completedRunCount: Int(completedRuns)
        )

        let jitaiGuidance = JITAIEngine.evaluate(
            state: state,
            protocol: protocols[selectedProtocolIndex]
        )
        reasoning = jitaiGuidance.reasoning

        // Build diagnostics
        let typesDesc: String
        if let types = jitaiGuidance.preferredTypes {
            typesDesc = types.map(\.displayName).sorted().joined(separator: ", ")
        } else {
            typesDesc = "(all — no type filter)"
        }

        let kwDesc = jitaiGuidance.indicationKeywords.isEmpty
            ? "(none)"
            : jitaiGuidance.indicationKeywords.joined(separator: ", ")

        let excludeDesc = jitaiGuidance.contraindicationExclusions.isEmpty
            ? "(none)"
            : jitaiGuidance.contraindicationExclusions.joined(separator: ", ")

        // Run selector to get candidates
        let query = InterventionSelector.Query(
            types: jitaiGuidance.preferredTypes,
            indicationKeywords: jitaiGuidance.indicationKeywords,
            excludeContraindications: jitaiGuidance.contraindicationExclusions,
            applyACTBoundary: true
        )
        let candidates = InterventionSelector.select(query: query)
        let candidateList = candidates.prefix(5).enumerated().map { i, t in
            "  \(i + 1). \(t.name) (\(t.type.displayName))"
        }.joined(separator: "\n")

        diagnostics = """
        State sent:
          capturedIntensity: \(Int(capturedIntensity))
          urge: \(selectedUrge?.displayName ?? "nil")
          completedRuns: \(Int(completedRuns))
          lastRun: \(Int(lastRunHoursAgo))h ago @ \(Int(lastRunIntensity))
          measureDue: \(hasDueMeasure), activeExperiment: \(hasActiveExperiment)

        JITAI output:
          Types: \(typesDesc)
          Keywords: \(kwDesc)
          Exclude: \(excludeDesc)

        Candidates (\(candidates.count)):
        \(candidateList)
        """

        let result = engine.recommendIntervention(state: state)
        switch result {
        case .intervention(let instance):
            recommendation = "\(instance.title) (\(instance.type.displayName))\n\n\(instance.script)"
        case .action(let action):
            recommendation = "Action: \(action.type.rawValue)\n\n\(action.message)"
        }
    }

    private func evaluateReview() {
        let engine = ProtocolEngine(cbtProtocol: protocols[selectedProtocolIndex])
        let fakeChanges = (0..<Int(completedRuns)).map { _ in Double.random(in: -15...5) }
        reviewResults = engine.evaluateReviewRules(
            completedRunCount: Int(completedRuns),
            recentEmotionChanges: fakeChanges
        )
    }
}
