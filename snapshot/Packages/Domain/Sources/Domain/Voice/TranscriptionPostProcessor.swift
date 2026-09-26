import Foundation

/// Cleans up raw transcription text for insertion into text fields.
public enum TranscriptionPostProcessor {

    /// Process raw transcription output: trim, capitalise, ensure trailing punctuation.
    public static func process(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        var result = trimmed

        // Capitalise the first character
        let first = result.removeFirst()
        result = String(first).uppercased() + result

        // Add period if no trailing punctuation
        let lastChar = result.last!
        if !lastChar.isPunctuation {
            result.append(".")
        }

        return result
    }
}
