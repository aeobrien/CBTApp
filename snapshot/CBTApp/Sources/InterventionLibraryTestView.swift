import SwiftUI
import Domain
import DesignSystem

/// Test view for browsing and parameterising intervention templates.
struct InterventionLibraryTestView: View {
    var body: some View {
        List {
            ForEach(InterventionLibrary.allTemplates) { template in
                NavigationLink {
                    InterventionTemplateDetailView(template: template)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(template.name)
                                .font(.headline)
                            Spacer()
                            Text(template.type.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(CBTColors.accent.opacity(0.12)))
                                .foregroundStyle(CBTColors.accent)
                        }
                        Text(template.indication)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Intervention Library")
    }
}

struct InterventionTemplateDetailView: View {
    let template: InterventionTemplate
    @State private var hotThought = ""
    @State private var urgeBehaviour = ""
    @State private var targetSituation = ""
    @State private var parameterisedInstance: InterventionInstance?

    var body: some View {
        List {
            Section("Template Info") {
                LabeledContent("Type", value: template.type.displayName)
                LabeledContent("Duration", value: "\(template.durationEstimate / 60)m")
                LabeledContent("Timed", value: template.type.isTimed ? "Yes" : "No")
                Text(template.indication)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Evidence") {
                Text(template.evidenceBasis)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Contraindications") {
                ForEach(template.contraindications, id: \.self) { c in
                    Label(c, systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }

            Section("Steps") {
                ForEach(Array(template.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .top) {
                        Text("\(i + 1).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text(step)
                            .font(.subheadline)
                    }
                }
            }

            Section("Example Scripts") {
                ForEach(template.exampleScripts, id: \.self) { script in
                    Text(script)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }

            Section("Parameterise") {
                let placeholders = InterventionParameteriser.placeholders(in: template)

                if placeholders.contains("hotThought") {
                    TextField("Hot thought", text: $hotThought)
                }
                if placeholders.contains("urgeBehaviour") {
                    TextField("Urge behaviour", text: $urgeBehaviour)
                }
                if placeholders.contains("targetSituation") {
                    TextField("Target situation", text: $targetSituation)
                }

                Button("Generate Script") {
                    let context = InterventionParameteriser.Context(
                        hotThought: hotThought.isEmpty ? nil : hotThought,
                        targetSituation: targetSituation.isEmpty ? nil : targetSituation,
                        urgeBehaviour: urgeBehaviour.isEmpty ? nil : urgeBehaviour
                    )
                    parameterisedInstance = InterventionParameteriser.parameterise(
                        template: template,
                        context: context
                    )
                }

                if let instance = parameterisedInstance {
                    ScriptCard(
                        title: instance.title,
                        script: instance.script,
                        isTimed: instance.isTimed,
                        durationMinutes: instance.durationEstimate / 60
                    )

                    Text("\(instance.script.count)/\(InterventionParameteriser.maxScriptLength) chars")
                        .font(.caption2)
                        .foregroundStyle(
                            instance.script.count > InterventionParameteriser.maxScriptLength
                            ? .red : .secondary
                        )
                }
            }
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
