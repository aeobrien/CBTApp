# Session Log

## Session 1 — 2026-02-19

### Phase 0: Project Scaffolding ✅
- Xcode project created with XcodeGen (`project.yml`)
- 6 SPM packages: Domain, Data, Services, DesignSystem, Features, Utilities
- CBTLogger utility with os.Logger, subsystem/category/correlation ID support
- Category prefix `[CategoryName]` added to all log messages for text-based filtering
- Git repo initialised, committed on `main`
- Manual tests passed, committed

### Phase 1: Domain Models + Persistence ✅
- 10 enum types (EmotionType, UrgeType, BodySignal, OutcomeTag, ProtocolStatus, InterventionType, MeasureFrequency, RunCompletionStatus, MaintainingBehaviourType, TargetLoopType)
- 9 model types (CBTProtocol, Run, Formulation, InterventionInstance, InterventionTemplate, Experiment, StandardisedMeasure, Rules, SafetyInfo, CaptureField, RelapsePreventionCard)
- 3 repository protocols + 2 mock implementations
- 3 SwiftData @Model persistence classes (PersistedProtocol, PersistedRun, PersistedMeasureScore)
- 3 SwiftData repository implementations
- 3 realistic sample protocols (Late-Night Rumination, Comparison & Scrolling, Work Perfectionism)
- ContentView with protocol list + detail navigation
- 65 automated tests passing (Utilities 7, Domain 50, Data 8)
- Manual tests passed, committed on `phase-1/domain-models`

### Phase 2: Design System ✅
- Design tokens: CBTColors (semantic colours, component-specific), CBTTypography (Dynamic Type scale), CBTSpacing (4pt grid)
- 10 components: CBTSlider, BeliefStrengthSlider, SelectableChip + FlowLayout + ChipGrid, ProtocolCard, CBTTimerView + TimerModel, CBTChecklist, VoiceInputButton (UI only), OutcomeTagSelector, ScriptCard, SafetyBanner
- Component catalogue view (scrollable reference of all components in all states)
- 15 automated tests passing (Tokens 3, TimerModel 9, OutcomeTag 2, Module 1)
- Manual tests passed, committed on `phase-2/design-system`
- Fix applied: count-up timer centred with `.frame(maxWidth: .infinity)`

### Phase 3: Curated Intervention Library ✅
- 9 intervention templates covering all 8 InterventionType cases (2 behavioural experiment variants)
- InterventionParameteriser: substitutes `{{hotThought}}`, `{{urgeBehaviour}}`, `{{targetSituation}}`, lowercases first char for mid-sentence insertion, enforces 240-char limit
- InterventionSelector: query by type, contraindication exclusion, keyword relevance, ACT boundary rule
- Interactive test view with per-template placeholder detection (only shows relevant fields)
- 71 automated tests passing (original 50 + Library 5 + Parameteriser 7 + Selector 7 + placeholder/lowercase 2)
- Manual tests passed, committed on `phase-3/intervention-library`

### Phase 4: Protocol Engine + JITAI Logic ✅
- ProtocolEngine: loads protocol, ordered capture fields, recommends interventions via JITAI, evaluates review rules, checks due measures
- JITAIEngine: 6-level priority decision logic
  1. Measure due → prompt measure
  2. Active experiment → follow-up
  3. Recent run (<2h) + low intensity (<30) → outside-app action
  4. First run (completedRunCount == 0) → default to behavioural experiment
  5. Urge-based → type-specific intervention selection
  6. Intensity-based → severity-appropriate interventions
- ReviewRuleEvaluator: parses `runs >= N`, `after_N_runs`, `no_shift_after_N`, `no_shift_after_N_runs`
- Test harness view with auto-evaluate and diagnostics panel
- 108 automated tests passing (original 101 + 7 end-to-end pipeline tests)
- Fixes applied across two test rounds:
  - TC-02 fix: moved first-run check to priority 4 (before urge/intensity)
  - TC-06 fix: JITAI keyword "worry" didn't substring-match "worries" — changed to "worries"/"ruminat" stems
  - TC-07 fix: test harness UI improved (red slider for current intensity, auto-evaluate, diagnostics)
  - TC-08 fix: parser now handles `after_N_runs` format from sample data
- All manual tests passed (TC-01 through TC-09)
- Committed on `phase-4/protocol-engine`

### Phase 5: Run Mode — IN PROGRESS
- RunFlowStep enum (Domain) — 6 navigation cases
- RunSummary (Domain) — pure function generating human-readable summary text
- RunFlowViewModel (@Observable @MainActor) — single VM driving all 6 screens:
  - Protocol selection with search filtering
  - Capture: situation, hot thought, emotions (chip + slider), body signals, urge, belief strength
  - Guided discovery: prediction + alternative response
  - Intervention: JITAI-driven recommendation, timer, checklist, switch intervention
  - Outcome: re-rate emotions, belief strength, outcome tags, learning note, forward plan
  - Summary: generated text + thumbs up/down helpfulness rating
- 6 screen views using DesignSystem components (ProtocolCard, ScriptCard, CBTSlider, etc.)
- RunFlowCoordinator: NavigationStack with enum-based path
- ContentView: "Start a Run" entry point via full-screen cover
- Save on each screen transition (Run starts .abandoned, set to .completed at finish)
- Skip paths: skip capture, skip guided discovery
- 29 new automated tests (7 RunSummary + 22 RunFlowViewModel)
  - Domain: 108 total (101 existing + 7 new)
  - Features: 23 total (22 new + 1 existing)
- Manual test brief: `docs/manual-tests/phase-5-run-mode.md` (8 test cases)
- Awaiting manual testing

### Phase 7: Agent Service (OpenAI Integration) — BUILT, awaiting manual testing
- AgentServiceProtocol + supporting types (Domain): `AgentResult`, `ConversationMessage`, `GenerationContext`
- MockAgentService (Domain): configurable mock with call tracking
- OpenAI integration (Services):
  - `AgentServiceError`: 9-case error enum with localized descriptions
  - `OpenAITypes`: Codable request/response types for chat completions API
  - `KeychainHelper`: simple Keychain wrapper for API key storage
  - `OpenAIAPIClient`: actor with exponential backoff retry (429, 5xx), 30s timeout, API key from Keychain or override
  - `ConversationManager`: static enum building system prompts dynamically from all `CaseIterable` enums + `InterventionLibrary.allTemplates`, triple-layer JSON extraction
  - `ProtocolGenerationPipeline`: generate + validate + repair loop (max 3 attempts)
  - `ProtocolPatchPipeline`: revision pipeline preserving ID, incrementing minor version
  - `OpenAIAgentService`: top-level `AgentServiceProtocol` implementation composing all actors
- 28 new automated tests:
  - OpenAIAPIClient: 7 (success, headers, JSON mode, 429 retry, timeout, malformed, missing key)
  - ConversationManager: 8 (enum values, library IDs, constraints, JSON extraction ×3, revision prompt, toChatMessages)
  - ProtocolGenerationPipeline: 7 (valid response, repair on invalid script, 3× invalid → repairFailed, no JSON, invalid ID, network error, timestamps)
  - ProtocolPatchPipeline: 5 (version increment ×3, preserves ID, revision prompt)
- Total Services tests: 57 (29 existing + 28 new)
- Domain tests: 109 (unchanged)
- App builds on iOS Simulator
- AgentTestView test harness with API key entry, protocol generation, result display
- Manual test brief: `docs/manual-tests/phase-7-agent-service.md`

### Phase 9: Workshop Mode ✅
- 10-stage agent-led protocol construction workshop
- Domain additions:
  - `WorkshopStage` enum (10 stages with title, subtitle, stageNumber, isGuidedDiscovery)
  - `WorkshopPrompts` with per-stage system prompts + `WorkshopContext` struct
  - `FormulationBuilder` (progressive formulation assembly: fromCapture, addMaintainingCycles, setAppraisal, linkIntervention)
  - `WorkshopFlowViewModelProtocol` + `GenerationState` enum
- Features additions:
  - `WorkshopFlowViewModel` (@Observable, single VM for all stages, per-stage conversations, generation/revision)
  - `WorkshopFlowCoordinator` (NavigationStack + enum-based routing)
  - 3 shared components: `ConversationView` (chat UI), `FormulationView` (progressive diagram), `StageProgressBar`
  - 10 stage views: Stage1Capture through Stage9Generation
  - Stage 1: situation, hot thought, emotion picker, intensity, urge picker
  - Stages 2/3/4/6: guided discovery with agent conversation
  - Stage 3: maintaining behaviour picker with add/remove
  - Stage 4: target belief confirmation text field
  - Stage 5: intervention selection from library (filtered by relevance)
  - Stage 6: experiment design (conversation → structured fields)
  - Stage 7: capture field toggles
  - Stage 7.5: standardised measure selection with frequency picker
  - Stage 8: review rule management
  - Stage 9: generation with progress/success/failure states
- Revision mode: pre-fills state from existing protocol, calls `reviseProtocol()`
- New automated tests:
  - Domain: FormulationBuilderTests (10) + WorkshopPromptsTests (6) = 16 new
  - Features: WorkshopFlowViewModelTests (27) covering navigation, capture, guided discovery, interventions, generation, revision
  - Total Domain: 59 XCTest + 109 swift-testing = 168
  - Total Features: 75 XCTest + 1 swift-testing = 76
- App builds on iOS Simulator
- WorkshopTestView test harness (new + revision mode)
- Manual test brief: `docs/manual-tests/phase-9-workshop.md`

### Phase 10: Safety & Escalation System — BUILT, awaiting manual testing
- Safety detection system with 4 alert kinds:
  - **Acute risk**: regex classifier with self-referential pronoun filtering and metaphor exclusion (2 tiers: acute/elevated)
  - **Chronic non-response**: PHQ-9 score increase ≥5, item 9 suicidality detection
  - **Disengagement**: 14+ day gap since last completed run
  - **Compulsive use**: 6+ runs in 24h or 8 consecutive non-improving runs
- Domain layer: `SafetyAlert`, `SafetyAlertKind`, `SafetySystemProtocol`, `DisengagementDetector`, `CompulsiveUseDetector`, `MockSafetySystem`
- Services layer: `AcuteRiskClassifier`, `EscalationEvaluator`, `SafetySystem` (concrete implementation)
- Features layer: `SafetyResourcesView` + `.safetyCover()` view modifier (fullScreenCover on iOS, sheet on macOS)
- ViewModel integration:
  - `WorkshopFlowViewModel`: safety scan on sendMessage input and capture stage advance
  - `RunFlowViewModel`: safety scan on capture and outcome stage advance
  - Both coordinators wired with `.safetyCover()` modifier
- New automated tests:
  - Domain: DisengagementDetectorTests (6) + CompulsiveUseDetectorTests (6) = 12 new
  - Services: AcuteRiskClassifierTests (8) + EscalationEvaluatorTests (7) + SafetySystemCompositionTests (3) = 18 new
  - Total Domain: 71 XCTest + 109 swift-testing = 180
  - Total Services: 75 swift-testing
  - Total Features: 75 XCTest + 1 swift-testing = 76 (unchanged)
- App builds on iOS Simulator
- SafetyTestView test harness with quick-test buttons for all alert types
- Manual test brief: `docs/manual-tests/phase-10-safety.md`

## Session 4 — 2026-02-21

### Phase 15: Integration, Polish, Full Flow Testing ✅
- DependencyContainer: production (on-disk SwiftData + real services) and preview (in-memory + mocks)
- HomeView + HomeViewModel: production home screen with protocol list, Start a Run, Build New, Quick Triage, Settings
- ProtocolDetailView: dashboard wrapper with Run, Weekly Review, Revise, Measure Admin, Completion flows
- CBTApp.swift rewired: DependencyContainer created once, onboarding → post-onboarding Workshop → HomeView
- Auto-seeds SampleData into SwiftData on first launch (empty store)
- Whisper model auto-prepares on launch
- ContentView renamed to DebugMenuView, accessible via Debug button (#if DEBUG) in HomeView toolbar
- QuickTriageView made public for app target access
- CompletionCandidate made Identifiable for .sheet(item:) usage
- Accessibility pass on 7 DesignSystem components: ProtocolCard, ScriptCard, OutcomeTagSelector, CBTChecklist, VoiceInputButton, SafetyBanner (hint), CBTTimer
- 8 integration tests with in-memory SwiftData:
  1. Protocol saved and loadable
  2. Run saved and queryable (with DashboardStatsCalculator)
  3. Protocol revision saves new version
  4. Quick Triage finds matching protocol
  5. Safety system escalation evaluation
  6. Seed data populates empty store
  7. Delete protocol cascades to runs
  8. Measure scores persist and retrieve
- Test target dependencies trimmed (removed Services/Features/DesignSystem to avoid WhisperKit linker issues)
- Manual test brief: `docs/manual-tests/phase-15-integration.md` (6 end-to-end scenarios)
- All package tests pass: Domain 112, Utilities 7, Data 8, DesignSystem 15, Services 75, Features 109
- All app integration tests pass: 11 (3 existing + 8 new)
- App builds successfully for iOS Simulator

## Session 5 — 2026-03-01

### Workshop Flow Improvements (post-Phase 15 polish)
Three usability problems addressed from real-world Workshop usage:

**Problem 1: AI chat stages loop indefinitely** — no clear endpoint, assumes CBT knowledge.
- Added `introExplanation` and `goalDescription` computed properties to `WorkshopStage` for all 4 guided stages
- Added `StageIntroCard` to `ConversationView` — shows at top of scroll, explains what the stage does and what "done" looks like
- Added `COMPLETION` section to all 4 AI system prompts instructing the AI to summarise, nudge "tap Next", and stop asking questions

**Problem 2: Stage 2 captures no structured output** — AI gathers recurrence insights but nothing is extracted.
- Added `recurrenceTriggers: [String]`, `recurrenceFrequency: String?`, `recurrenceTimingPattern: String?` to `WorkshopContext`
- Added matching properties to `WorkshopFlowViewModelProtocol` and `WorkshopFlowViewModel`
- Removed inline `FormulationView` from `Stage2RecurrenceView`, replaced with structured capture section (trigger list with add/remove, frequency field, timing pattern field) appearing after ≥2 user messages
- Wired recurrence data into `buildWorkshopContext()`, `buildStructuredSummary()`, `loadExistingProtocol()`
- Injected recurrence context into downstream prompts (maintaining, targetBelief, experimentDesign)

**Problem 3: Stage 3 BehaviourPickerSheet loses detail** — creates `MaintainingBehaviour` with empty `shortTermRelief`/`longTermCost`.
- Revamped `BehaviourPickerSheet`: selecting a type now shows optional "Short-term relief" and "Long-term cost" text fields before adding
- Updated behaviour list display to show relief/cost details when present

**Files changed:**
- `Domain/Workshop/WorkshopPrompts.swift` — WorkshopContext + 4 prompt methods
- `Domain/Workshop/WorkshopStage.swift` — 2 new computed properties
- `Domain/Protocols/WorkshopViewModelProtocol.swift` — 3 new recurrence properties
- `Features/Workshop/WorkshopFlowViewModel.swift` — recurrence state + wiring
- `Features/Workshop/Shared/ConversationView.swift` — StageIntroCard
- `Features/Workshop/Stages/Stage2RecurrenceView.swift` — full rewrite
- `Features/Workshop/Stages/Stage3MaintainingView.swift` — BehaviourPickerSheet revamp

**New tests:**
- Domain: WorkshopStageTests (5) — intro/goal non-nil for guided, nil for others
- Domain: WorkshopPromptsTests (+8) — completion signals, recurrence context in downstream prompts
- Features: WorkshopFlowViewModelTests (+3) — recurrence properties, generation summary, revision pre-fill
- Total Domain: 112 (was 112, net +5 stage tests + 8 prompt tests, but swift-testing suite is separate)
- Total Features: 116 (was 109 XCTest + 1 swift-testing, now 115 XCTest + 1 swift-testing)

**Verification:** Domain 112 tests pass, Features 116 tests pass, app BUILD SUCCEEDED.

## Git State
- `main` branch: Phase 0 only
- `phase-1/domain-models`: Phase 0 + 1
- `phase-2/design-system`: Phase 0 + 1 + 2
- `phase-3/intervention-library`: Phase 0 + 1 + 2 + 3
- `phase-4/protocol-engine`: Phases 0–15 + Workshop improvements (all work on this branch)
