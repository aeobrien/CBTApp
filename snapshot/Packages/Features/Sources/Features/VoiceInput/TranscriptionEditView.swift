import SwiftUI
import DesignSystem

/// Edit-before-confirm sheet for voice transcription.
struct TranscriptionEditView: View {
    @Binding var text: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: CBTSpacing.md) {
                Text("Review transcription")
                    .font(CBTTypography.bodySecondary)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .font(.body)
                    .padding(CBTSpacing.xs)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3))
                    )
                    .frame(minHeight: 120)

                Spacer()
            }
            .padding(CBTSpacing.md)
            .navigationTitle("Voice Input")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Insert") { onConfirm() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    TranscriptionEditView(
        text: .constant("This is a test transcription."),
        onConfirm: {},
        onCancel: {}
    )
}
