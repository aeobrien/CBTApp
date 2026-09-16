# CBT App Development Roadmap

## Technical Stack

- **Platform**: iOS 17+
- **UI Framework**: SwiftUI with `@Observable` (Observation framework)
- **Data**: SwiftData
- **LLM**: OpenAI GPT-5.2 via API
- **Voice**: On-device Whisper model
- **IDE**: Xcode 16.x (Swift 6)
- **Architecture**: MVVM + Coordinator, modularised via Swift Package Manager
- **Testing**: XCTest (unit), XCUITest (UI), both simulator + physical device

---

## Development Workflow

Each phase follows the same cycle:

1. **Spec** — I describe exactly what the module does, its inputs/outputs, and its contract with the rest of the system
2. **Build** — I implement the module with full logging instrumentation
3. **Auto-test** — I write and run rigorous automated tests (unit + integration) and fix issues before you see anything
4. **Manual test brief** — I give you a concrete checklist of things to test in the simulator/device, what to look for, and how to capture logs
5. **Your feedback** — You run the tests, paste logs or describe behaviour, I fix issues
6. **Commit** — Only after both testing tiers pass

### Logging Convention

Every module uses Apple's `os.Logger` API with:
- **Subsystem**: `com.cbt.app`
- **Category**: module name (e.g., `ProtocolEngine`, `RunMode`, `AgentService`)
- **Levels**: `.debug` for flow tracing, `.info` for state changes, `.error` for failures
- **Correlation IDs**: each Run and Workshop session gets a UUID that tags all related log entries

When you encounter an issue, you filter logs in Xcode's console by category and paste the relevant lines to me.

### Git Convention

- One branch per module/phase
- Commits only after tests pass
- Merge to `main` only after manual QA sign-off

---

## Module Dependency Graph

```
Phase 0: Scaffolding
    ↓
Phase 1: Domain Models + Persistence
    ↓
Phase 2: Design System (UI components)
    ↓
Phase 3: Curated Intervention Library
    ↓
Phase 4: Protocol Engine + JITAI Logic
    ↓
Phase 5: Run Mode (6 screens)
    ↓                           ↘
Phase 6: Validation Pipeline     Phase 8: Evidence & Review
    ↓                           ↗
Phase 7: Agent Service (OpenAI)
    ↓
Phase 9: Workshop Mode
    ↓
Phase 10: Safety & Escalation System
    ↓
Phase 11: Voice Input (Whisper)
    ↓
Phase 12: Onboarding / Psychoeducation
    ↓
Phase 13: Quick Triage
    ↓
Phase 14: Settings, Export, Protocol Completion
    ↓
Phase 15: Integration, Polish, Full Flow Testing
```

---

## Phase 0: Project Scaffolding

**Goal**: Xcode project, SPM module structure, logging infrastructure, CLAUDE.md, test harness.

### 0.1 — Create Xcode project + SPM package structure

- Xcode project: `CBTApp`
- SPM packages organised into layers:
  - `Domain/` — protocols, entities, enums (no dependencies)
  - `Data/` — SwiftData persistence, repository implementations (depends on Domain)
  - `Services/` — Agent service, validation, safety (depends on Domain)
  - `DesignSystem/` — reusable UI components (depends on Domain for model types)
  - `Features/` — feature modules: RunMode, Workshop, Evidence, Onboarding, etc. (depends on all above)
  - `Utilities/` — logging, extensions, helpers (no dependencies)
- App target imports all packages

### 0.2 — Logging infrastructure

- `CBTLogger` utility wrapping `os.Logger`
- One logger per module with consistent subsystem/category
- Correlation ID support (pass through async contexts)
- Debug-only verbose mode toggle

### 0.3 — CLAUDE.md + project documentation

- Root CLAUDE.md with architecture, build/test commands, coding patterns
- Per-module CLAUDE.md files added as each module is built

**Auto-tests**: Build compiles, empty test target runs, logger outputs to console.
**Manual test**: Open project in Xcode, build and run, confirm blank app launches and logs appear in console.

---

## Phase 1: Domain Models + Persistence

**Goal**: All data models, SwiftData schema, and repository protocols — the foundation everything else depends on.

### 1.1 — Core domain entities

Swift types for all protocol JSON spec objects:

- `CBTProtocol` (id, version, name, summary, status, when_to_use, hot_thought_templates, maintaining_behaviours, targets, capture_fields, interventions, experiments, measures, review_rules, safety, formulation, standardised_measures, escalation_rules, completion_summary, relapse_prevention_card)
- `Run` (run_id, protocol_id, timestamps, capture payload, chosen interventions, completion status, before/after measures, guided_discovery_responses, learning, forward_plan, helpfulness_rating, note)
- `Experiment` (prediction, steps, measures, success_criteria, outcomes)
- `Formulation` (trigger_appraisal_links, maintaining_cycles)
- `InterventionInstance` (references intervention_id from library, parameterised scripts)
- `StandardisedMeasure` (measure_id, frequency, scores history)
- `EscalationRule` (trigger, action)
- `ReviewRule` (condition, action)
- All supporting enums: EmotionType, UrgeType, BodySignal, OutcomeTag, ProtocolStatus, InterventionType, MeasureFrequency, etc.

### 1.2 — SwiftData persistence layer

- `@Model` classes for all persistent entities
- Repository protocols in Domain layer:
  - `ProtocolRepositoryProtocol` (CRUD + query by status, search)
  - `RunRepositoryProtocol` (CRUD + query by protocol, date range, stats)
  - `MeasureRepositoryProtocol` (CRUD + query by measure type, date)
- Concrete SwiftData implementations in Data layer
- Versioned schema migration support

### 1.3 — Mock data + preview support

- `MockProtocolRepository`, `MockRunRepository`, etc.
- Sample protocols with realistic data (at least 3 diverse examples)
- Preview helpers that inject mock data into SwiftUI previews

**Auto-tests**:
- Create, read, update, delete for every entity type
- Query filtering (by status, date, protocol_id)
- Schema migration from empty to v1
- Enum encoding/decoding round-trips
- Edge cases: empty arrays, maximum-length strings, boundary slider values (0, 100)
- Concurrent read/write safety
- JSON encoding/decoding of Protocol objects (validates the JSON spec)

**Manual test**: I provide a test view that displays all mock protocols and runs in a scrollable list. You confirm data appears correctly and tap through CRUD operations.

---

## Phase 2: Design System

**Goal**: All reusable UI components, built and previewed in isolation.

### 2.1 — Core components

- `CBTSlider` — large, thumb-friendly, 0–100, labelled
- `EmotionChip` / `UrgeChip` / `ContextChip` — tappable tag chips with selection state
- `ProtocolCard` — card for protocol suggestions (name, summary, last used)
- `CBTTimer` — prominent but calm countdown/countup timer with start/pause
- `CBTChecklist` — max 5 items, tappable checkboxes
- `VoiceInputButton` — microphone button (UI only in this phase; actual transcription in Phase 11)
- `OutcomeTagSelector` — multi-select tag group
- `BeliefStrengthSlider` — specialised slider for belief rating
- `ScriptCard` — displays intervention script text
- `SafetyBanner` — unobtrusive emergency resources link

### 2.2 — Typography, colour, and layout tokens

- Colour palette (light + dark mode)
- Type scale (consistent across app)
- Spacing/padding tokens
- No streaks, badges, confetti, or gamification elements

### 2.3 — Component catalogue view

- A single scrollable view showing every component in every state (selected, unselected, disabled, dark mode, light mode)
- This becomes a reference for all future development

**Auto-tests**:
- Snapshot tests for every component in light/dark mode
- Accessibility audit (Dynamic Type, VoiceOver labels)
- Slider value binding correctness
- Chip selection/deselection state management
- Timer accuracy (start, pause, resume, reset)

**Manual test**: I provide the component catalogue view. You scroll through every component, test taps, sliders, timer, chips in both light and dark mode. Confirm visual quality and interaction feel on both simulator and device.

---

## Phase 3: Curated Intervention Library

**Goal**: The static library of evidence-based intervention templates that the agent selects from.

### 3.1 — Intervention template data model

Already defined in Phase 1, but here we populate:

- `InterventionTemplate` with all fields: intervention_id, type, indication, contraindications, steps, example_scripts (parameterised), duration_estimate, success_criteria, evidence_basis

### 3.2 — Initial template set

Create templates for each type:
- `behavioural_experiment` (at least 2 variants)
- `defusion` (with ACT-bounded indication/contraindication)
- `graded_exposure_step`
- `behavioural_activation`
- `delay_experiment`
- `opposite_action`
- `rumination_scheduling`
- `problem_solving_step`

### 3.3 — Template parameterisation engine

- Function that takes a template + user-specific context (hot thought, target belief, specific language) and produces a parameterised `InterventionInstance`
- Validates that parameterised scripts stay within character limits (≤ 240 chars)

### 3.4 — Template query/selection logic

- Query by type, indication match, contraindication exclusion
- Defusion deprioritised when behavioural experiment is feasible (ACT boundary rule)

**Auto-tests**:
- All templates pass schema validation
- Parameterisation produces valid scripts within character limits
- Contraindication logic correctly excludes inappropriate templates
- ACT boundary: defusion only suggested when behavioural experiment isn't feasible
- Edge: parameterisation with very long user input (truncation handling)
- Edge: empty indication match (returns fallback)
- Round-trip: template → parameterised instance → JSON → decode

**Manual test**: I provide a view listing all intervention templates with a "parameterise" button. You enter sample hot thoughts/beliefs and see the parameterised scripts. Confirm they read naturally and are appropriately specific.

---

## Phase 4: Protocol Engine + JITAI Logic

**Goal**: The engine that loads a protocol, recommends interventions, evaluates adaptation rules, and drives the run flow.

### 4.1 — Protocol engine core

- Load and parse `CBTProtocol` from SwiftData
- Render `capture_fields` in specified order
- Select recommended intervention based on JITAI decision logic
- Track protocol version and tie outcomes to versions

### 4.2 — JITAI adaptation logic

Decision rules implementation:
- Time-of-day matching against historical run data
- Recency check (last run <2h ago + low intensity → suggest outside-app action)
- Active experiment detection → prompt follow-up
- Standardised measure due → prompt measure
- Intensity-based intervention selection
- Urge-based intervention selection

### 4.3 — Review rule evaluation

- After N runs → trigger review prompt
- No shift after M runs → trigger revision prompt
- Standardised measure trend evaluation

**Auto-tests**:
- Protocol loading from SwiftData + field rendering order
- JITAI rules: test each decision branch with crafted input states
- Intervention recommendation: correct template selected for given intensity/urge/time combinations
- Review rule triggers at correct thresholds
- Edge: protocol with no experiments, no standardised measures
- Edge: first-ever run (no historical data for JITAI)
- Edge: conflicting rules (verify priority ordering)

**Manual test**: I provide a test harness view where you can select a mock protocol, set simulated conditions (time, last run recency, intensity), and see which intervention/action the engine recommends. Confirm recommendations feel sensible.

---

## Phase 5: Run Mode (6 Screens)

**Goal**: The complete in-the-moment run flow, end to end, using mock data.

### 5.1 — Screen A: Protocol Selection

- Search bar filtering protocols by name + triggers
- "Suggested" section (top 3 from JITAI logic)
- "I'm not sure" button (placeholder → Phase 13)
- "Emergency resources" link (always present)

### 5.2 — Screen B: Capture

- Situation (text + voice button placeholder)
- Hot thought selection from protocol templates + edit
- Emotion picker (fixed list + slider 0–100)
- Body signals tick list
- Urge single-choice
- "Skip capture" option

### 5.3 — Screen C: Brief Guided Discovery

- Display captured hot thought
- "What does this thought predict?" (text input + tap-to-select from protocol predictions)
- "What's an alternative possibility?" (text input + tap-to-select)
- Skippable ("Skip to action")

### 5.4 — Screen D: Do (Intervention)

- Show recommended intervention from engine
- Script display
- Timer (if timed intervention)
- Checklist (if checklist intervention)
- "Switch intervention" / "Mark as not helpful"

### 5.5 — Screen E: Outcome

- Emotion now slider(s)
- Belief strength now
- Outcome tags
- "What did you learn?" (optional)
- "One thing to try before next run" (optional)
- Optional note

### 5.6 — Screen F: Summary

- Auto-generated summary
- "Was this run helpful?" (thumbs up/down)
- Skippable

### 5.7 — Run flow coordinator

- Navigation between screens
- Run object creation and persistence
- Timestamp management
- Partial run saving (if user exits mid-run)

**Auto-tests**:
- Complete run flow: start → capture → discovery → do → outcome → summary → save
- Skip capture flow: start → skip → do → outcome → summary → save
- Skip guided discovery flow: start → capture → skip → do → outcome → summary → save
- Skip summary flow: start → ... → outcome → skip → save
- All screen state bindings (slider values, selections, text entries persist through navigation)
- Run object saved with all expected fields
- Partial run: exit at each screen, verify partial data saved
- Timer accuracy on intervention screen
- Edge: no protocol templates to select from
- Edge: intervention with no timer and no checklist

**Manual test**: Detailed walkthrough instructions for the complete run flow. You run 3 different protocols through the full flow, testing skip options, slider interactions, text entry, timer, checklist. Test on both simulator and device. Focus on: does it feel fast? Is the flow clear? Any friction points?

---

## Phase 6: Validation Pipeline

**Goal**: The system that validates protocol JSON from the agent before accepting it.

### 6.1 — JSON schema validator

- Validates all required fields present
- Validates field types and formats
- Validates enum values against controlled lists

### 6.2 — Constraint validator

- Scripts ≤ 240 characters
- `when_to_use` entries ≤ 80 characters
- At least one "actionable" intervention
- Experiment completeness (prediction, steps, measures, success_criteria)
- All intervention_ids reference valid library entries

### 6.3 — Content policy validator

- No medical instructions
- No harmful content
- Basic keyword/pattern checks

### 6.4 — Validation error reporting

- Structured error objects with field path, error type, message
- Suitable for feeding back to agent in repair loop

**Auto-tests**:
- Valid protocol passes all checks
- Missing required field → specific error
- Invalid enum value → specific error
- Script over 240 chars → specific error
- Experiment missing prediction → specific error
- Invalid intervention_id → specific error
- Content policy violations detected
- Multiple simultaneous errors all reported
- Edge: valid protocol with all optional fields empty
- Edge: valid protocol with all optional fields populated
- Edge: unicode characters, emoji in text fields

**Manual test**: I provide a view where you can paste or edit protocol JSON and see validation results. You try intentionally malformed protocols and confirm error messages are clear and specific.

---

## Phase 7: Agent Service (OpenAI Integration)

**Goal**: The service that communicates with GPT-5.2 to generate and repair protocols.

### 7.1 — OpenAI API client

- HTTP client for OpenAI chat completions API
- API key management (stored in Keychain)
- Request/response logging (content logged at debug level only)
- Error handling (rate limits, network failures, timeouts)
- Retry logic with backoff

### 7.2 — Workshop conversation manager

- Manages multi-turn conversation state for Workshop stages
- System prompt construction (includes intervention library, schema spec, constraints)
- Sends structured context, never full history
- Extracts JSON from agent responses
- Separates explanatory text from machine-readable output

### 7.3 — Protocol generation pipeline

- Agent outputs protocol JSON
- Feed through validation pipeline (Phase 6)
- If invalid: automatic repair loop — send validation errors back to agent
- Maximum repair attempts (3) before surfacing error to user
- Successfully validated protocol → save to SwiftData

### 7.4 — Protocol patch/revision pipeline

- Load existing protocol
- Send formulation + revision context to agent
- Agent outputs patch
- Apply patch + validate
- Save new version

**Auto-tests**:
- API client: mock HTTP responses for success, rate limit, timeout, malformed response
- Conversation manager: verify system prompt includes required constraints
- Repair loop: mock agent returning invalid JSON → verify error sent back → mock valid JSON → verify acceptance
- Repair loop: mock 3 consecutive failures → verify user-facing error
- Protocol generation: end-to-end with mocked agent returning valid protocol → verify saved to SwiftData
- Patch pipeline: existing protocol + mock patch → verify version increment
- Edge: agent returns no JSON block in response
- Edge: agent returns JSON that passes schema but fails constraint validation

**Manual test**: I provide a test view with a "Generate test protocol" button that calls the live API. You watch the generation process, see the validation results, and review the generated protocol. Test the repair loop by inspecting logs when the agent's first attempt has errors.

---

## Phase 8: Evidence & Review

**Goal**: Protocol dashboard, charts, weekly review, standardised measure tracking.

### 8.1 — Protocol dashboard

- Run count, average pre/post emotion change
- Belief strength trend line chart
- Common urges/maintaining behaviour tags
- Experiment outcomes
- Standardised measure trends (when available)
- Controls: revise, archive, export, reset metrics

### 8.2 — Weekly review

- 3–5 insight cards generated from run data
- Standardised measure references when available
- "One suggested revision"
- Controls: ignore, revise now, remind me

### 8.3 — Standardised measure administration

- Standalone questionnaire flow (PHQ-9, GAD-7)
- Triggered by frequency schedule, outside of runs
- Score calculation and storage
- Trend tracking

### 8.4 — Protocol completion pathway

- Sustained improvement detection
- "What did you learn?" prompt
- Relapse prevention card generation
- Completed protocol tracking (separate from archived)

**Auto-tests**:
- Dashboard stats calculation from mock run data
- Belief strength trend with 0, 1, 5, 20 runs
- Weekly review insight generation (correct time-of-day detection, avg calculations)
- Standardised measure scoring (PHQ-9, GAD-7 correct scoring algorithms)
- Measure due-date calculation
- Protocol completion triggers at correct thresholds
- Relapse prevention card contains correct fields
- Edge: protocol with no completed runs
- Edge: standardised measures with single data point (no trend)
- Edge: all runs show "got worse" — verify revision prompt

**Manual test**: I provide the dashboard pre-populated with mock data showing various scenarios (improving, stagnating, worsening). You review charts, trigger weekly review, complete a standardised measure questionnaire, and test the protocol completion flow.

---

## Phase 9: Workshop Mode

**Goal**: The full agent-led protocol construction flow with guided discovery.

### 9.1 — Workshop flow coordinator

- 9-stage navigation (Stage 1 through Stage 9, including Stage 7.5)
- Progress indicator
- Back navigation (revise earlier stages)
- Voice input integration points (placeholder until Phase 11)

### 9.2 — Stage implementations

Each stage as a separate SwiftUI view + ViewModel:

- **Stage 1**: Capture single instance (situation, hot thought, emotion, urge)
- **Stage 2**: Guided discovery — agent asks open questions about recurrence
- **Stage 3**: Guided discovery — agent asks about maintaining behaviours
- **Stage 4**: Guided discovery — agent scaffolds target belief generation
- **Stage 5**: Intervention selection from curated library with agent rationales
- **Stage 6**: Guided discovery — agent scaffolds experiment design
- **Stage 7**: Define capture fields and measures
- **Stage 7.5**: Suggest standardised measures + baseline capture
- **Stage 8**: Review rules (defaults pre-filled)
- **Stage 9**: JSON generation, validation, repair loop

### 9.3 — Formulation visualisation

- Progressive formulation display (trigger → appraisal → emotion → behaviour → cost)
- Updated after each stage
- User can see and confirm the emerging model

### 9.4 — Protocol revision mode

- Load existing protocol into Workshop
- Pre-fill stages with current values
- Agent context includes previous formulation + run history summary
- Produces versioned patch

**Auto-tests**:
- Full workshop flow with mocked agent: all 9 stages → valid protocol generated
- Each stage in isolation: correct inputs collected, correct agent context sent
- Formulation progressively built across stages
- Revision mode: existing protocol loaded correctly, patch applied
- Back navigation: earlier stage data preserved
- Edge: user provides minimal input at each stage
- Edge: agent fails at Stage 9 → repair loop works within Workshop flow
- Edge: user exits Workshop mid-flow → partial state preserved for resumption

**Manual test**: Full Workshop walkthrough with the live API. I provide a scenario to work through (e.g., "You notice you're ruminating about a work email at 11pm"). You complete all stages, observe guided discovery questioning, review the generated protocol. Then test revision by modifying one element.

---

## Phase 10: Safety & Escalation System

**Goal**: Acute risk detection, chronic non-response, disengagement detection.

### 10.1 — Acute risk classifier

- Lightweight keyword/pattern classifier for self-harm cues
- Triggers on Workshop text input and optional notes
- Response: stop generation, show resources screen

### 10.2 — Safety resources screen

- UK crisis numbers and links
- Calm, non-alarmist design
- "Continue with non-sensitive content" option
- Always-accessible from emergency resources link

### 10.3 — Chronic non-response detection

- Evaluate standardised measure trends
- PHQ-9 increase ≥ 5 points over 2 administrations → escalation
- Multiple protocols with no improvement → escalation
- Response: calm message, professional support resources, option to pause

### 10.4 — Disengagement detection

- No completed runs in 14 days → gentle notification
- Option to archive protocol or seek support

### 10.5 — Compulsive use detection

- Excessive runs without behaviour change → suggest outside-app action
- Optional Workshop/chat cooldown

**Auto-tests**:
- Acute classifier: true positives (known crisis phrases), true negatives (benign content), false positive rate check on sample text
- Escalation triggers: mock standardised measure data hitting thresholds
- Disengagement: mock date calculations for 14-day absence
- Compulsive use: mock run patterns → detection fires correctly
- Edge: classifier with unicode, metaphorical language
- Edge: measure data just below threshold → no trigger
- Edge: measure data exactly at threshold → trigger

**Manual test**: I provide a test view for each safety path. You type sample text to test the acute classifier, review the resources screen design, and trigger escalation/disengagement flows with simulated data. Confirm tone is calm and non-alarmist.

---

## Phase 11: Voice Input (Whisper)

**Goal**: On-device speech-to-text throughout the app.

### 11.1 — Whisper model integration

- On-device Whisper model (whisper-small or whisper-base, configurable)
- Model download/bundling strategy
- Real-time transcription pipeline
- No audio persistence — discard after transcription

### 11.2 — Voice input UI integration

- Replace placeholder VoiceInputButton with functional implementation
- Microphone button on all free-text fields
- Real-time transcription display
- Edit-before-confirm flow
- Microphone permission handling

### 11.3 — Post-processing

- Punctuation insertion
- Basic cleanup (filler word removal optional)

**Auto-tests**:
- Transcription pipeline with sample audio files (various accents, lengths)
- Audio discarded after transcription (no file persistence)
- Permission denied handling
- Edge: very short utterance (<1 second)
- Edge: silence
- Edge: background noise

**Manual test**: Test voice input on physical device across all text fields in Run Mode and Workshop Mode. Speak natural sentences and review transcription accuracy. Test in quiet and noisy environments. Confirm audio is not persisted (check device storage).

---

## Phase 12: Onboarding / Psychoeducation

**Goal**: First-launch interactive sequence.

### 12.1 — Psychoeducation screens

- What's a hot thought (with examples)
- What's a maintaining behaviour (with examples)
- Why we test rather than argue
- What a protocol is and how it helps
- ~2 minute total, interactive (not just text)

### 12.2 — Flow into first Workshop

- "Let's try this with something real" → launches Workshop
- Skip option for experienced users

### 12.3 — First-launch detection

- Persist onboarding completion state
- Show only on first launch (or if user resets)

**Auto-tests**:
- Onboarding flow: all screens navigate correctly
- Skip takes user to main app
- Completion persisted (second launch skips onboarding)
- Edge: force-quit during onboarding → resumes correctly

**Manual test**: Delete app data, relaunch. Walk through the complete onboarding. Confirm content is clear, concise, non-condescending. Confirm it flows into Workshop. Relaunch — confirm onboarding is skipped.

---

## Phase 13: Quick Triage

**Goal**: The "I'm not sure" wizard from Run Mode.

### 13.1 — 3-question wizard

1. "What's the main urge?" (list selection)
2. "What's the theme?" (loss/comparison/fear of failure/perfectionism/social threat/uncertainty)
3. "How intense?" (0–100 slider)

### 13.2 — Protocol matching logic

- Score existing protocols against triage answers
- Suggest best match or offer to build new one (→ Workshop)

**Auto-tests**:
- Matching logic returns correct protocol for known inputs
- No match → "build new" suggestion
- Edge: tied scores between protocols
- Edge: no protocols exist yet → always suggests Workshop

**Manual test**: With several protocols loaded, run the triage wizard with different answers. Confirm suggestions feel appropriate. Test the "build new" path.

---

## Phase 14: Settings, Export, Protocol Completion

**Goal**: User settings, data export/import, passcode/FaceID.

### 14.1 — Settings screen

- Passcode / Face ID toggle
- Dark mode override
- Workshop cooldown setting
- Notification preferences
- "What gets sent to the agent" disclosure
- API key management

### 14.2 — Export/import

- Export protocol library as JSON
- Export run history as JSON
- Import protocol from JSON file
- Share sheet integration

### 14.3 — Protocol lifecycle management

- Archive protocol
- Complete protocol (triggers completion flow from Phase 8)
- Delete protocol (with confirmation)
- Reset metrics

**Auto-tests**:
- Export produces valid JSON that can be re-imported
- Import handles invalid JSON gracefully
- Settings persist across app launches
- Face ID toggle (mock biometric context)
- Edge: export with no data
- Edge: import protocol with unknown intervention_ids

**Manual test**: Toggle all settings, confirm persistence. Export protocols, inspect JSON file. Import a protocol from file. Test Face ID lock on physical device.

---

## Phase 15: Integration, Polish, Full Flow Testing

**Goal**: Wire everything together, end-to-end flows, performance, final QA.

### 15.1 — Full flow integration

- Connect onboarding → Workshop → Run Mode → Evidence → Review
- Verify all module boundaries work correctly
- Navigation from any screen to any other via appropriate paths

### 15.2 — Performance profiling

- App launch time
- Run mode screen-to-screen transition speed
- SwiftData query performance with large datasets (100+ protocols, 1000+ runs)
- Memory usage during Workshop (agent conversation)

### 15.3 — Accessibility audit

- Full VoiceOver pass
- Dynamic Type at all sizes
- Colour contrast verification

### 15.4 — End-to-end scenarios

- New user: onboarding → first Workshop → first Run → review dashboard
- Returning user: Run from suggestion → complete → check dashboard
- Protocol revision: dashboard → revise → Workshop → updated protocol → Run
- Protocol completion: sustained improvement → completion flow → relapse prevention card
- Escalation: worsening measures → escalation prompt → resources
- Quick triage → matched protocol → Run

**Auto-tests**:
- Integration tests for each end-to-end scenario above
- Performance benchmarks (fail if launch >2s, screen transition >0.3s)
- Memory leak detection

**Manual test**: Comprehensive walkthrough of every end-to-end scenario. This is the full QA pass. I provide a detailed script for each scenario with expected behaviour at every step.

---

## Estimated Module Count

| Phase | Modules | Depends on |
|-------|---------|------------|
| 0 | 3 (project, logging, CLAUDE.md) | — |
| 1 | 3 (entities, SwiftData, mocks) | Phase 0 |
| 2 | 3 (components, tokens, catalogue) | Phase 0 |
| 3 | 4 (templates, data, parameterisation, query) | Phase 1 |
| 4 | 3 (engine, JITAI, review rules) | Phases 1, 3 |
| 5 | 7 (6 screens + coordinator) | Phases 1, 2, 4 |
| 6 | 4 (schema, constraints, content, errors) | Phase 1 |
| 7 | 4 (API client, conversation, generation, patch) | Phases 1, 3, 6 |
| 8 | 4 (dashboard, weekly review, measures, completion) | Phases 1, 2, 4 |
| 9 | 4 (coordinator, stages, formulation viz, revision) | Phases 1–8 |
| 10 | 5 (classifier, resources, chronic, disengage, compulsive) | Phases 1, 8 |
| 11 | 3 (Whisper, UI integration, post-processing) | Phase 2 |
| 12 | 3 (screens, flow, detection) | Phases 1, 2 |
| 13 | 2 (wizard, matching) | Phases 1, 2, 4 |
| 14 | 3 (settings, export, lifecycle) | Phases 1, 2 |
| 15 | 4 (integration, performance, a11y, e2e) | All |
