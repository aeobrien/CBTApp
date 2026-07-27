import Foundation

/// Queries and selects intervention templates from the library.
///
/// Implements the ACT boundary rule: defusion is deprioritised
/// when a behavioural experiment is feasible.
public enum InterventionSelector {

    /// Query options for filtering templates.
    public struct Query: Sendable {
        public var types: Set<InterventionType>?
        public var indicationKeywords: [String]
        public var excludeContraindications: [String]
        /// When true, deprioritise defusion if a behavioural experiment matches.
        public var applyACTBoundary: Bool

        public init(
            types: Set<InterventionType>? = nil,
            indicationKeywords: [String] = [],
            excludeContraindications: [String] = [],
            applyACTBoundary: Bool = true
        ) {
            self.types = types
            self.indicationKeywords = indicationKeywords
            self.excludeContraindications = excludeContraindications
            self.applyACTBoundary = applyACTBoundary
        }
    }

    /// Select matching templates from the library, ordered by relevance.
    public static func select(
        query: Query,
        from templates: [InterventionTemplate] = InterventionLibrary.allTemplates
    ) -> [InterventionTemplate] {
        var results = templates

        // Filter by type if specified
        if let types = query.types {
            results = results.filter { types.contains($0.type) }
        }

        // Exclude templates whose contraindications match any of the exclusion strings
        if !query.excludeContraindications.isEmpty {
            results = results.filter { template in
                !template.contraindications.contains { contraindication in
                    query.excludeContraindications.contains { exclusion in
                        contraindication.localizedCaseInsensitiveContains(exclusion)
                    }
                }
            }
        }

        // Score by indication keyword match
        if !query.indicationKeywords.isEmpty {
            results.sort { a, b in
                indicationScore(a, keywords: query.indicationKeywords) >
                indicationScore(b, keywords: query.indicationKeywords)
            }
        }

        // ACT boundary: if behavioural experiments are in results,
        // move defusion to the end
        if query.applyACTBoundary {
            let hasBE = results.contains { $0.type == .behaviouralExperiment }
            if hasBE {
                let defusion = results.filter { $0.type == .defusion }
                let nonDefusion = results.filter { $0.type != .defusion }
                results = nonDefusion + defusion
            }
        }

        return results
    }

    /// Score how well a template's indication matches the query keywords.
    private static func indicationScore(
        _ template: InterventionTemplate,
        keywords: [String]
    ) -> Int {
        keywords.reduce(0) { score, keyword in
            score + (template.indication.localizedCaseInsensitiveContains(keyword) ? 1 : 0)
        }
    }
}
