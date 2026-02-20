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

## Git State
- `main` branch: Phase 0 only
- `phase-1/domain-models`: Phase 0 + 1
- `phase-2/design-system`: Phase 0 + 1 + 2
- `phase-3/intervention-library`: Phase 0 + 1 + 2 + 3
- `phase-4/protocol-engine`: Phase 0 + 1 + 2 + 3 + 4

## Remaining Roadmap (Phases 5–15)
See `/Users/aidan/Dev/CBT/ROADMAP.md` for full details:
- Phase 5: Run Mode (6 screens)
- Phase 6: Validation Pipeline
- Phase 7: Agent Service (OpenAI GPT-5.2)
- Phase 8: Evidence & Review
- Phase 9: Workshop Mode
- Phase 10: Safety & Escalation
- Phase 11: Voice Input (Whisper)
- Phase 12: Onboarding / Psychoeducation
- Phase 13: Quick Triage
- Phase 14: Settings, Export, Protocol Completion
- Phase 15: Integration, Polish, Full Flow Testing
