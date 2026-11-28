# MentalHealthToolkit — Technical Brief

## Technology Stack

**Swift 6** with strict concurrency. Both existing apps use Swift 6 and the unified app continues this. Strict concurrency checking catches data race issues at compile time, which matters for an app handling concurrent voice transcription, AI API calls, and UI updates.

**SwiftUI with @Observable / @Bindable** (iOS 17 Observation framework). Both existing apps use this pattern rather than Combine. The unified app targets iOS 17.0 minimum deployment.

**SwiftData** for on-device persistence. Both existing apps use SwiftData with the repository pattern (protocol abstractions with SwiftData and mock implementations). All data stays on-device — no cloud sync at v1.0. In-memory ModelContainer configuration for testing.

**OpenAI GPT API** (currently GPT-5.2) via direct REST calls. No SDK dependency. Both existing apps use this approach with a validation/repair loop for structured outputs. The service layer is model-agnostic — the underlying model can be swapped without architectural changes.

**WhisperKit** for on-device voice transcription. The CBT app has a mature implementation (AVAudioRecorder → resample to 16kHz → WhisperKit transcription, raw audio discarded immediately). The DBT app has the UI ready but the backend deferred. The unified app uses the CBT app's implementation as the reference.

**XcodeGen** for project generation from `project.yml`. **SPM** for modularisation into 6 packages. Both existing apps use this identical build infrastructure.

**os.Logger** via a custom structured logging wrapper (CBTLogger in the CBT app) with categories and correlation IDs.

**LocalAuthentication** for optional app lock.

No changes to the technology stack from the existing apps. The stack is proven across both codebases and the unified app inherits it directly.

## Architecture

### Overall Structure

MVVM architecture with Coordinator pattern, organised into 6 SPM packages with a thin app shell. This is identical to both existing apps.

```
┌─────────────────────────────────────┐
│          App Shell                  │
│  Entry point, DI container, routing │
├──────────┬──────────┬───────────────┤
│ Features │DesignSys │   Services    │
│ (Flows)  │(UI Kit)  │ (Agent, Voice,│
│          │          │  Safety, Lib) │
├──────────┴──────────┴───────────────┤
│              Domain                 │
│  (Models, Enums, Technique Schema,  │
│   Triage Rules, Safety Rules)       │
├─────────────────────────────────────┤
│         Data (Persistence)          │
│     SwiftData repositories          │
├─────────────────────────────────────┤
│           Utilities                 │
│       (Logging, Helpers)            │
└─────────────────────────────────────┘
```

**Dependency injection** via a single `DependencyContainer` created at app launch and passed down. All services defined as protocols enabling mock substitution for testing.

**Repository pattern** with protocol abstractions (`SessionRepositoryProtocol`, `CheckInRepositoryProtocol`, `ProtocolRepositoryProtocol`, `SkillsPlanRepositoryProtocol`) and both SwiftData and mock implementations.

### Triage Pipeline

The core architectural addition to the existing pattern. A five-layer hybrid pipeline that alternates between deterministic code and AI judgment:

**Layer 1 — Safety Classification (Code, deterministic).** Regex-based crisis detection adapted from the CBT app's Acute Risk Classifier. Self-referential pronoun prefix to reduce metaphor false positives. Two-tier classification: acute (blocks session, surfaces safety resources) and elevated (flags to agent, user can continue). Runs on every user input throughout the session, not just at intake.

**Layer 2 — Structured Signal Extraction (Code, deterministic).** Processes capture data into a set of flags and constraints: intensity level and routing signals (intensity ≥80 flags toward Category 1), energy level (filters technique pool by energy demand), alexithymia flag ("I don't know" on emotion selector triggers body-sensation routing), active commitments from previous sessions (database query), recent technique history and diversity recommendations (query against session history). Output is a structured context object passed to the AI layer.

**Layer 3 — Conversational Assessment (AI).** The agent interprets the user's free text or voice input, informed by the structured signals from Layer 2, and determines the functional category. This is where genuine judgment lives — distinguishing intrusive thoughts (Category 2) from rumination loops (Category 3) from examinable beliefs (Category 4). The agent communicates its assessment as a structured JSON object: `category` (primary assessment), `confidence` (high/medium/low), `reasoning_summary` (brief text), and optionally `secondary_category` (for presentations spanning two categories). The code layer parses this using the same validation/repair loop pattern established in both existing apps — if parsing fails, a repair prompt is sent.

**Layer 4 — Technique Filtering (Code, deterministic).** Filters the technique library by: selected functional category, energy level constraints, contraindications, and diversity weighting (deprioritising recently overused techniques). Produces a shortlist of eligible techniques passed to the AI layer.

**Layer 5 — Technique Selection and Presentation (AI).** The agent selects the most appropriate technique from the filtered shortlist and presents it to the user conversationally, explaining why it's suggesting this approach. Includes validation-before-change: acknowledges the user's experience before orienting them to the technique.

**Continuous monitoring:** Layer 1 (safety) runs on every user input throughout the session. The code layer also monitors for disengagement signals (short responses, long pauses, explicit "this isn't helping" feedback, escalating intensity). If disengagement is detected, the system re-invokes the triage configuration with updated context, allowing the agent to re-assess and pivot.

**Known limitation — cooperative engagement with wrong technique.** The course-correction mechanism detects explicit user feedback and observable disengagement, but cannot detect a user who is cooperatively engaging with a mismatched technique. A user doing a thought record when they needed grounding may produce normal-looking session interactions. Two partial mitigations exist: the validation-before-change step creates a natural checkpoint where the user can redirect ("It sounds like you have a specific thought to examine — would you like to work through that?"), and the outcome feedback loop self-corrects over time (consistently low helpfulness ratings for a category path cause the diversity weighting in Layer 4 to deprioritise it). The system learns from its mistakes across sessions rather than catching every mistake within a single session.

### System Prompt Architecture

Discrete prompt configurations swapped at stage transitions, following the pattern established in both existing apps. Each configuration is focused — the agent does one job at a time.

**Base layer (always present):** Core identity and role, safety constraints and content policy, validation-before-change requirement, scope limitations (no diagnosis, no prescribing, curated techniques only), the user's current session context (capture data, structured flags from the code layer), relevant history summary (recent technique usage, active commitments, patterns).

**Triage configuration (assessment phase):** Added on top of base. Contains functional category definitions with entry signals, instructions for conversational assessment, and the structured JSON output format for communicating the category assessment back to the code layer. Removed once triage is complete.

**Guide configuration (technique execution phase):** Swapped in once a technique is selected. Contains the specific technique's steps, script templates, and placeholder tokens, plus category-specific interaction guidance (directive for Category 1, Socratic for Category 4, holding for Category 5). Only includes guidance for the active category. Includes a lightweight exit ramp instruction: if the user explicitly says the approach isn't helping, acknowledge gracefully and signal readiness to try something different.

**Outcome configuration (reflection phase):** Facilitates post-technique reflection, captures outcome data, and supports optional commitment-making. Lighter than the guide configuration.

Prompts are dynamically assembled by the code layer, not stored as monolithic strings. The code layer selects which configuration to apply based on session state, constructs it with current context data, and manages transitions between configurations.

## Data Model

### Session (core entity)

A single flat `@Model` entity with a small non-optional core and mostly optional fields. This continues the pattern used in both existing apps, where Run entities already have optional fields for features that aren't always used. The session flow's UI determines what's presented and collected; the data model does not enforce fields that legitimate session paths might skip.

**Non-optional core:**
- `id: UUID` — stable identifier
- `timestamp: Date` — session start
- `duration: TimeInterval` — session length
- `sessionType: SessionType` — enum: full, quick, exploration
- `initialCategory: FunctionalCategory` — category assessed at triage (or manually selected)
- `finalCategory: FunctionalCategory` — category at session end (same as initial unless course-correction occurred)
- `initialTechniqueID: String` — technique selected at triage
- `finalTechniqueID: String` — technique at session end (same as initial unless pivot occurred)

**Capture fields (optional — populated based on session path):**
- `captureEmotions: [EmotionRating]?` — array of emotion + intensity pairs. Nil on alexithymia path.
- `captureBodySensations: [BodySensation]?` — multi-select
- `captureBodyDistress: Int?` — 0-100
- `captureUrge: UrgeRating?` — urge type + intensity
- `captureSituation: String?` — free text description. Nil on quick path.
- `captureEnergyLevel: EnergyLevel?` — enum: low, medium, high. Defaults if not explicitly set.
- `emotionUnknown: Bool` — alexithymia flag (non-optional, defaults false)
- `hotThought: String?` — the specific distorted thought being examined. Populated for Category 4 sessions, nil otherwise. Clinically valuable for tracking belief change over time.

**Technique execution fields (optional):**
- `techniqueParameterData: Data?` — encoded parameterised technique instance

**Outcome fields (optional — populated at session end):**
- `outcomeEmotions: [EmotionRating]?` — post-session emotions
- `outcomeIntensityChange: Int?` — delta from pre to post
- `outcomeTags: [OutcomeTag]?` — structured outcome indicators
- `outcomeLearningNote: String?` — free text reflection
- `outcomeHelpfulness: Int?` — rating
- `commitmentText: String?` — optional post-session commitment
- `commitmentFulfilled: Bool?` — tracked at next session
- `summaryText: String?` — auto-generated session summary

**Triage metadata (optional):**
- `agentTriageReasoning: String?` — summary of the agent's category assessment
- `triageConfidence: String?` — high/medium/low from the agent's structured response
- `secondaryCategory: FunctionalCategory?` — if the presentation spanned two categories

**Modality-specific fields (optional, from CBT app):**
- `beliefStrengthBefore: Int?` — 0-100
- `beliefStrengthAfter: Int?` — 0-100
- `experimentPrediction: String?`
- `experimentOutcome: String?`
- `guidedDiscoverySummary: String?`

**Modality-specific fields (optional, from DBT app):**
- `chainRecognitionResult: String?`
- `skillStepCompletions: [String]?` — tracking which steps of multi-step skills were completed

**Relationships (optional):**
- `protocol: PersistedProtocol?` — link to CBT protocol (for migrated historical data)
- `skillsPlan: PersistedSkillsPlan?` — link to DBT skills plan (for migrated historical data)

New sessions created through the triage flow will have nil protocol and skillsPlan relationships. These exist to preserve historical data from migration.

**Expected field population by session type:**

*Full session:* All capture fields presented and encouraged. Emotions are the default starting point; alexithymia path substitutes body sensations. Situation description, energy level, and urges presented. All outcome fields collected. Triage metadata populated if AI triage was used.

*Quick session:* Minimal capture — emotion (single select) + intensity. Situation, body sensations, urges skipped. Technique defaults to grounding (Phase 3) or is triage-selected from minimal data (Phase 6). Outcome is intensity change only.

*Exploration session:* User is browsing or trying a technique without a specific presenting problem. Capture may be sparse. Outcome data still collected.

### DailyCheckIn (separate entity)

A separate `@Model` entity, not a Session subtype. Different purpose and lifecycle — a quick daily snapshot with no technique execution, no triage, no AI conversation.

- `id: UUID`
- `date: Date`
- `emotions: [EmotionRating]?` — same type as Session uses
- `bodySensations: [BodySensation]?`
- `bodyDistress: Int?` — 0-100
- `strongestUrge: UrgeRating?`
- `targetBehaviours: [String]?` — from user-configured list
- `techniquesUsed: [String]?` — technique IDs from recent sessions
- `overallDistress: Int?` — 0-100
- `freeText: String?`
- `skipped: Bool` — true if user opened check-in but didn't complete it. A pattern of opening and skipping is a different signal from not opening at all.

### Shared Value Types

Defined once in the Domain package, used by both Session and DailyCheckIn:

- `EmotionRating` — emotion enum + intensity (0-100). The emotion enum is the shared vocabulary also used by the companion journaling app.
- `BodySensation` — constrained enum of body sensation types
- `UrgeRating` — urge type enum + intensity (0-100)
- `OutcomeTag` — enum of structured outcome indicators
- `FunctionalCategory` — enum: grounding, unhooking, breakingRumination, examiningBeliefs, sittingWithEmotions, valuesAndForward
- `EnergyLevel` — enum: low, medium, high
- `SessionType` — enum: full, quick, exploration

### Coexisting Legacy Entities

`PersistedProtocol` (from CBT app) and `PersistedSkillsPlan` (from DBT app) are migrated as-is into the unified data layer. They are not unified into a single abstraction — they coexist as separate entity types. Sessions have optional relationships to either. No new protocols or plans are created at v1.0 (Workshop is out of scope); these entities exist purely to preserve and display historical data.

### SafetyPlan

Promoted from the DBT app to a system-level entity. User-configurable: emergency contacts, personal coping strategies, warning signs, reasons for living. Surfaced during crisis-level events. Optional but encouraged during onboarding.

### Technique Library (not a SwiftData entity)

The technique library is a read-only JSON configuration resource loaded at runtime. It is not persisted in SwiftData. Sessions reference techniques by `technique_id` string. The library contains 27 techniques at v1.0 with the following schema per entry:

- `technique_id` — unique stable identifier
- `name` — human-readable
- `description` — what it does and when it's useful
- `functional_categories` — array of primary and secondary category assignments
- `modality_origin` — provenance tag (cbt, dbt), not user-facing
- `evidence_basis` — brief note on supporting evidence
- `indication_keywords` — array for triage matching
- `contraindications` — conditions under which this technique should not be offered
- `energy_demand` — low, medium, or high
- `steps` — array of- `steps` — array of structured steps (instruction text, duration estimate, user input type, completion criteria)
- `placeholder_tokens` — parameterisable fields with descriptions
- `duration_estimate` — estimated minutes
- `quick_path_eligible` — boolean
- `script_templates` — example scripts with {{placeholder}} tokens for the AI agent to personalise
- `success_criteria` — how to assess whether the technique was helpful

## Key Decisions

**Data-driven technique library over compiled enums.** Both existing apps use static Swift enums/structs for their technique definitions. The unified library moves to JSON configuration loaded at runtime. This enables adding techniques without recompilation, adjusting parameters and metadata independently of code changes, and maintaining the library as a reviewable, editable resource separate from the codebase. The tradeoff is losing compile-time type safety on technique references — mitigated by validation at load time and tests that verify all referenced technique_ids exist in the library.

**Hybrid triage pipeline over pure AI assessment.** The triage system alternates between deterministic code layers and AI judgment rather than relying entirely on the AI agent. Code handles safety classification, structured signal extraction, and technique filtering. The AI handles conversational interpretation and technique presentation. This makes safety detection reliable and testable, constrains the AI's decision space to genuine judgment calls, and enables unit testing of the deterministic layers with full coverage.

**Discrete prompt configurations over fluid full-context prompts.** The system prompt is swapped at stage transitions (triage → guide → outcome) rather than including all instructions at all times. This reduces token cost, prevents the agent from drifting into irrelevant behaviour, and follows the proven pattern from both existing apps where stage-specific prompts produce more reliable agent behaviour.

**Flat Session entity over linked extensions.** Modality-specific fields are optional properties on a single Session entity rather than separate linked entities. This continues the pattern both existing apps already use, avoids join complexity, and keeps queries simple. The number of optional fields is bounded and manageable (under 10 modality-specific fields at v1.0). Future technique-specific data needs (imagery rescripting's TargetMemory, ACT values clarification's persistent Values entity) will be handled as purpose-built entities when those techniques are added in v1.x.

**Separate DailyCheckIn entity over Session subtype.** The daily check-in has a different purpose and lifecycle from therapeutic sessions. Making it a Session subtype would add dead weight (technique reference, triage reasoning, outcome data) and require filtering logic everywhere sessions are queried. Separate entity, shared value types.

**Build-new-using-existing-as-source over merge-two-codebases.** The unified app is constructed as a new codebase that pulls from the existing apps as source material, rather than attempting to merge two codebases directly. This means only the components needed for v1.0 scope are ported — Workshop ViewModels, the CBT evidence dashboard, and the DBT diary card trends view stay in their original repos as reference material. This narrows Phase 1 significantly and avoids refactoring code that isn't needed yet.

**Coexisting legacy plan entities over premature unification.** CBTProtocol and SkillsPlan are migrated as separate entity types rather than unified into a single Plan abstraction. With Workshop out of scope for v1.0, no new plans are created — these entities exist to preserve historical data. Unification can be revisited when Workshop returns in a future version, with the benefit of real usage data from the unified triage system to inform the design.

**Manual technique selection before AI triage.** Phase 3 builds the full session flow with manual category and technique selection. AI triage is added in Phase 5. This means a working, useful app exists after three phases, the session flow is tested independently of triage complexity, and the developer can use the app daily while the triage system is being developed.

## Integration Points

**OpenAI GPT API.** Direct REST calls for the AI agent (triage assessment, technique guidance, session facilitation). Validation/repair loop for structured outputs — if the agent's response doesn't parse into the expected format, the system sends a repair prompt. No SDK dependency. Model-agnostic service layer: the current model (GPT-5.2) can be swapped without architectural changes.

**WhisperKit.** On-device voice transcription on all free-text fields. AVAudioRecorder captures audio, resamples to 16kHz, WhisperKit transcribes, raw audio is discarded immediately. Model (base/small/medium variants) downloaded on first use, seeded on app launch. Ported from the CBT app's mature implementation.

**Shared emotion vocabulary.** The constrained emotion enum is defined now and shared (by convention, not by code dependency) with the companion journaling app project. This preserves future integration compatibility — both projects use the same emotion list from the start — without requiring cross-system architecture at v1.0. No runtime integration between the two apps exists at v1.0.

No other external integrations. No cloud services, no analytics, no third-party frameworks beyond WhisperKit.

## Constraints

**iOS 17.0 minimum deployment.** Required for the Observation framework (@Observable/@Bindable) and SwiftData, both of which are foundational to the architecture.

**On-device only.** All user data stored locally in SwiftData. No cloud sync, no remote backup at v1.0. This is a privacy-by-design constraint, not a deferral of convenience — the user controls what data leaves the device.

**Privacy by design.** The AI agent receives summaries and aggregates, never full session transcripts or raw diary data. Voice recordings are discarded immediately after transcription. No telemetry, no analytics. Export capability exists for the user to optionally share data with their therapist.

**Curated technique library.** The AI agent selects from the pre-defined, validated technique library. It cannot invent, modify, or improvise therapeutic techniques. This is a hard safety constraint enforced by the prompt architecture (the agent only sees techniques from the filtered shortlist) and by code-level validation (technique_id in the session must exist in the library).

**Content policy.** Enforced in both the AI agent's system prompt and code-level validation: no medical dosage instructions, no self-harm methods, no diagnostic statements, no prescribing language, safety resources included for any interaction touching life-threatening content, agent cannot recommend discontinuing professional treatment.

**Single user.** The app is designed for one user. No multi-user support, no account system, no authentication beyond optional app lock.

## Implementation Order

### Phase 1: Foundation
Build the new unified repository with the 6-package SPM structure. Merge Utilities, DesignSystem packages. Build the unified Domain package with shared value types (emotion enums, body sensation types, intensity representations, outcome tags, functional category enum). Build the unified Data package with the Session entity, DailyCheckIn entity, and repositories. Port coexisting CBTProtocol and SkillsPlan entities for migration support. Refactor only the ViewModels needed for the v1.0 session flow (capture, guidance, outcome screens) — Workshop and dashboard ViewModels stay in original repos as reference.

**Depends on:** Nothing. Starting point.
**Produces:** Compilable unified codebase with shared infrastructure, data layer, and design system.

### Phase 2: Technique Library
Convert all 27 existing techniques from compiled enums/structs to JSON format with full metadata schema. Build the JSON loader with validation (verify all required fields present, all technique_ids unique, all enum values valid). Build the generalised parameteriser interface (adapted from CBT app's InterventionParameteriser) that fills placeholder tokens with user-specific language.

**Depends on:** Phase 1 (Domain package for shared types referenced by technique metadata).
**Produces:** Complete, validated technique library loadable at runtime. Parameteriser ready for use in session flow.

### Phase 3: Session Flow (Manual Selection)
Implement the full session flow: Capture → Validate & Orient → Guide → Outcome & Commit → Summary. User manually selects functional category and technique (no AI triage yet). The Guide step uses the technique's steps and script templates from the JSON library, parameterised with capture data. Outcome step captures post-session emotions, intensity change, helpfulness rating, learning note, and optional commitment. Summary auto-generated. Quick path also implemented here as a minimal 3-screen flow with a hardcoded grounding default (no selection logic — Phase 6 adds intelligent selection).

**Depends on:** Phase 1 (data layer, UI components), Phase 2 (technique library and parameteriser).
**Produces:** A working, usable app. The developer can begin daily use with manual technique selection while subsequent phases add intelligence. Quick path functional with sensible default.

### Phase 4: Safety Architecture
Port and unify the CBT app's regex-based crisis classifier (Layer 1 of the triage pipeline). Build the continuous monitoring layer that runs safety classification on every user input throughout a session, not just at intake. Port the DBT app's SafetyPlan entity and UI. Implement two-tier response: acute (block session, surface safety plan + crisis resources) and elevated (flag to agent context, user continues). Implement content policy validation in the code layer. Build pattern-based escalation rules (intensity trends, disengagement detection). Ensure always-accessible crisis resources UI.

**Depends on:** Phase 3 (session flow to integrate safety monitoring into).
**Produces:** Complete safety architecture. Required before AI triage goes live.

### Phase 5: AI Triage System
Build the full five-layer triage pipeline. Layer 2: structured signal extraction from capture data (intensity routing, energy filtering, alexithymia flag, commitment check, diversity weighting). Layer 3: AI conversational assessment with triage prompt configuration and structured JSON response format (category, confidence, reasoning, optional secondary category) with validation/repair loop. Layer 4: code-level technique filtering (category + energy + contraindications + diversity). Layer 5: AI technique selection with guide prompt configuration. Build discrete prompt configurations (base, triage, guide, outcome) with dynamic assembly. Build the course-correction mechanism: code detects disengagement signals, re-invokes triage with updated context. Replace manual category/technique selection with AI-driven triage as the default flow (manual selection remains available as override).

**Depends on:** Phase 3 (session flow), Phase 4 (safety layers that triage pipeline builds on).
**Produces:** The core differentiating feature — AI-guided technique selection based on conversational assessment.

### Phase 6: Quick Path Upgrade and Daily Check-In
Upgrade the quick path from Phase 3's hardcoded grounding default to triage-driven automatic technique selection based on minimal capture data (emotion + intensity), user history, and previously effective techniques. Implement the DailyCheckIn entity and UI: emotions with intensity, body sensations, strongest urge with intensity, target behaviours, techniques used, overall distress, optional free-text/voice note, skip tracking. Brief, tap-driven, completable in 1-2 minutes.

**Depends on:** Phase 3 (quick path UI and flow), Phase 5 (triage system for intelligent technique selection).
**Produces:** Low-friction entry points for low-capacity moments and daily self-monitoring.

### Phase 7: Voice Integration and Data Migration
Port the CBT app's WhisperKit implementation to all free-text fields across the unified app. Build the data migration pipeline: map CBT app's PersistedRun to unified Session (with CBT-specific optional fields populated), map DBT app's PersistedRun similarly, preserve Protocol and SkillsPlan relationships, validate migrated data against originals. Build minimal historical data viewing UI (read-only display of migrated protocols and plans — not the full Workshop editing interface).

**Depends on:** Phase 1 (data layer with migration-compatible entities), Phase 3 (session flow with voice input points).
**Produces:** Voice input throughout the app. Historical data preserved and accessible.

### Phase 8: Alexithymia Path and Onboarding
Implement body-sensation routing: when the user selects "I don't know" on the emotion selector, the capture flow routes through body sensation selection first, and the triage system infers emotional state from somatic experience. The agent's language adapts accordingly. Build minimal onboarding orientation: what the app does, how to use it, brief explanation of the session flow. Not a full psychoeducation module — enough to make the app usable on first launch.

**Depends on:** Phase 5 (triage system to integrate alexithymia-aware routing into), Phase 3 (capture flow).
**Produces:** Complete v1.0 feature set. All Definition of Done criteria met.

## Risks and Uncertainties

**AI triage reliability (highest risk).** The conversational assessment in Layer 3 of the triage pipeline is the genuinely novel component. Distinguishing between functional categories from natural language — particularly the subtle distinctions between intrusive thoughts (Category 2), rumination (Category 3), and examinable beliefs (Category 4) — requires judgment that may not be reliable across all presentations. Mitigation: the triage system is built on top of a working manual-selection app (Phase 3 before Phase 5), so triage failures degrade to "user selects manually" rather than "app is unusable." Course-correction mechanism allows recovery from wrong initial assessments. Extensive testing with representative user inputs across all six categories before relying on triage as the default flow. See also the known limitation documented in the Triage Pipeline section regarding cooperative engagement with mismatched techniques.

**Data migration fidelity.** The CBT app is actively in use with real session history that has practical and emotional value. Migration must preserve data accurately, including relationships between sessions and protocols. Mitigation: build migration with validation (compare migrated records against originals), implement rollback capability, test against real data before cutting over. Migration is a one-time operation but failure is costly.

**Validation-before-change enforcement.** The DBT app enforces validation structurally by scanning agent responses for validation language. Generalising this across all interactions means the scanning logic must work across different conversational contexts — validating before a grounding exercise sounds different from validating before Socratic questioning. Too rigid produces false negatives; too loose misses absent validation. Mitigation: build a test corpus of representative agent responses across all six categories, tune the validation detector against it, accept that some edge cases will require iteration.

**Agent behaviour consistency across categories.** The guide configuration asks the AI to behave in genuinely different conversational modes: directive for Category 1, Socratic for Category 4, gentle and holding for Category 5. The risk is that the agent defaults to a single comfortable style regardless of category guidance. Mitigation: test per category with representative scenarios, consider whether category-specific prompt tuning is needed beyond what the configuration provides, iterate on prompt language based on observed behaviour.

**Technique parameterisation at scale.** Generalising the parameteriser from 9 CBT techniques to 27 unified techniques with varying step structures (a TIPP breathing exercise looks nothing like a Behavioural Experiment) requires a flexible but maintainable interface. Mitigation: design the parameteriser interface around the most structurally diverse techniques first, validate that it handles the full range before committing to the pattern.

**Monolithic ViewModel refactoring scope.** The session flow ViewModels from both apps need refactoring into per-screen ViewModels during Phase 1. This is necessary work but could take longer than expected if the existing ViewModels have tightly coupled logic. Mitigation: only refactor ViewModels needed for v1.0 scope (session flow screens), leave Workshop and dashboard ViewModels in original repos. The refactoring scope is bounded by the v1.0 feature set.
