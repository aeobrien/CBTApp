# Roadmap

## Next Up
<!-- Highest priority incomplete tasks across all phases -->

| Task | Milestone | Phase | Status | Effort |
|------|-----------|-------|--------|--------|
| 1.1.1 Build unified repository with 6-package SPM structure | 1.1 Repository and Package Structure | 1: Foundation | Todo | Deep Focus |
| 1.2.1 Build unified Domain package with shared value types | 1.2 Domain and Data Layer | 1: Foundation | Todo | Deep Focus |
| 2.1.1 Convert 27 techniques from compiled enums to JSON | 2.1 Technique Library | 2: Technique Library | Todo | Deep Focus |

---

## Phase 1: Foundation
**Status:** Todo
**Definition of Done:** Compilable unified codebase with shared infrastructure, data layer, and design system.

### 1.1 — Repository and Package Structure
**Status:** Todo
**Priority:** High
**Definition of Done:** New unified repo with 6 SPM packages (Utilities, DesignSystem, Domain, Data, Services, Features) and thin app shell.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 1.1.1 | Build unified repository with 6-package SPM structure | Todo | Deep Focus | | |
| 1.1.2 | Merge Utilities packages from both apps | Todo | Deep Focus | | |
| 1.1.3 | Merge DesignSystem packages from both apps | Todo | Deep Focus | | |

### 1.2 — Domain and Data Layer
**Status:** Todo
**Priority:** High
**Definition of Done:** Unified Domain package with shared value types, unified Data package with Session, DailyCheckIn, and legacy entities.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 1.2.1 | Build unified Domain package (emotion enums, body sensations, functional categories, etc.) | Todo | Deep Focus | | Shared emotion vocabulary compatible with companion journaling app |
| 1.2.2 | Build unified Data package with Session entity | Todo | Deep Focus | | Flat entity with optional modality-specific fields |
| 1.2.3 | Build DailyCheckIn entity and repository | Todo | Deep Focus | | Separate entity, shared value types |
| 1.2.4 | Port CBTProtocol and SkillsPlan for migration support | Todo | Deep Focus | | Coexisting legacy entities |
| 1.2.5 | Refactor ViewModels needed for v1.0 session flow | Todo | Deep Focus | | Only session flow VMs — leave Workshop/dashboard in original repos |

---

## Phase 2: Technique Library
**Status:** Todo
**Definition of Done:** Complete, validated technique library loadable at runtime with generalised parameteriser.

### 2.1 — Technique Library
**Status:** Todo
**Priority:** High
**Definition of Done:** All 27 techniques in JSON with full metadata schema, loader with validation, and parameteriser interface.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 2.1.1 | Convert 27 techniques from compiled enums to JSON format | Todo | Deep Focus | | Full metadata: categories, energy, indications, contraindications, steps, scripts |
| 2.1.2 | Build JSON loader with validation | Todo | Deep Focus | | Verify required fields, unique IDs, valid enum values |
| 2.1.3 | Build generalised parameteriser interface | Todo | Deep Focus | | Adapted from CBT app's InterventionParameteriser |

---

## Phase 3: Session Flow (Manual Selection)
**Status:** Todo
**Definition of Done:** Working app with full and quick session flows using manual category/technique selection.

### 3.1 — Full Session Flow
**Status:** Todo
**Priority:** High
**Definition of Done:** Complete flow: Capture, Validate & Orient, Guide, Outcome & Commit, Summary.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 3.1.1 | Implement Capture screen (emotions, body sensations, situation, energy) | Todo | Deep Focus | | |
| 3.1.2 | Implement manual category and technique selection | Todo | Deep Focus | | Replaced by AI triage in Phase 5 |
| 3.1.3 | Implement Guide screen with technique steps and script templates | Todo | Deep Focus | | |
| 3.1.4 | Implement Outcome screen (post-session emotions, helpfulness, learning note) | Todo | Deep Focus | | |
| 3.1.5 | Implement Summary screen with auto-generated summary | Todo | Deep Focus | | |
| 3.1.6 | Implement optional commitment capture | Todo | Deep Focus | | |

### 3.2 — Quick Path
**Status:** Todo
**Priority:** Normal
**Definition of Done:** Minimal 3-screen flow with hardcoded grounding default.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 3.2.1 | Build quick capture screen | Todo | Deep Focus | | |
| 3.2.2 | Build quick technique screen (grounding default) | Todo | Deep Focus | | Upgraded to triage-driven in Phase 6 |
| 3.2.3 | Build quick outcome screen | Todo | Deep Focus | | |

---

## Phase 4: Safety Architecture
**Status:** Todo
**Definition of Done:** Complete safety system with two-tier crisis detection, safety plan, content policy, and escalation rules.

### 4.1 — Crisis Detection and Response
**Status:** Todo
**Priority:** High
**Definition of Done:** Regex-based crisis classifier runs on every user input, two-tier response, always-accessible crisis resources.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 4.1.1 | Port and unify regex-based crisis classifier from CBT app | Todo | Deep Focus | | Self-referential pronoun prefix to reduce false positives |
| 4.1.2 | Build continuous safety monitoring (every user input) | Todo | Deep Focus | | |
| 4.1.3 | Implement two-tier response (acute blocking, elevated warning) | Todo | Deep Focus | | |
| 4.1.4 | Port SafetyPlan entity and UI from DBT app | Todo | Deep Focus | | |
| 4.1.5 | Build always-accessible crisis resources UI | Todo | Deep Focus | | |

### 4.2 — Content Policy and Escalation
**Status:** Todo
**Priority:** High
**Definition of Done:** Content policy enforced in system prompt and code, pattern-based escalation rules implemented.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 4.2.1 | Implement content policy validation in code layer | Todo | Deep Focus | | |
| 4.2.2 | Build pattern-based escalation rules (intensity trends, disengagement) | Todo | Deep Focus | | |

---

## Phase 5: AI Triage System
**Status:** Todo
**Definition of Done:** Five-layer hybrid triage pipeline operational as default flow with course-correction.

### 5.1 — Triage Pipeline
**Status:** Todo
**Priority:** High
**Definition of Done:** All five layers functional: safety classification, signal extraction, conversational assessment, technique filtering, technique selection.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 5.1.1 | Build Layer 2: structured signal extraction from capture data | Todo | Deep Focus | | |
| 5.1.2 | Build Layer 3: AI conversational assessment with JSON response format | Todo | Deep Focus | | Validation/repair loop for structured outputs |
| 5.1.3 | Build Layer 4: code-level technique filtering | Todo | Deep Focus | | Category + energy + contraindications + diversity |
| 5.1.4 | Build Layer 5: AI technique selection and presentation | Todo | Deep Focus | | |
| 5.1.5 | Build discrete prompt configurations (base, triage, guide, outcome) | Todo | Deep Focus | | Dynamic assembly by code layer |
| 5.1.6 | Build course-correction mechanism (disengagement detection, re-triage) | Todo | Deep Focus | | |
| 5.1.7 | Replace manual selection with AI triage as default (manual remains as override) | Todo | Deep Focus | | |

---

## Phase 6: Quick Path Upgrade and Daily Check-In
**Status:** Todo
**Definition of Done:** Quick path uses triage-driven selection; daily check-in implemented.

### 6.1 — Quick Path Upgrade
**Status:** Todo
**Priority:** Normal
**Definition of Done:** Quick path uses AI triage on minimal capture data instead of hardcoded grounding.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 6.1.1 | Upgrade quick path to triage-driven technique selection | Todo | Deep Focus | | |

### 6.2 — Daily Check-In
**Status:** Todo
**Priority:** Normal
**Definition of Done:** DailyCheckIn UI captures emotions, body sensations, urges, target behaviours, techniques used, distress, and free text. Completable in 1-2 minutes.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 6.2.1 | Build daily check-in UI | Todo | Deep Focus | | Tap-driven, brief |
| 6.2.2 | Implement skip tracking | Todo | Quick Win | | Opening but not completing is a distinct signal |

---

## Phase 7: Voice Integration and Data Migration
**Status:** Todo
**Definition of Done:** WhisperKit on all free-text fields, historical data migrated from both apps.

### 7.1 — Voice Integration
**Status:** Todo
**Priority:** Normal
**Definition of Done:** On-device WhisperKit transcription available on all free-text fields, raw audio discarded immediately.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 7.1.1 | Port WhisperKit implementation from CBT app | Todo | Deep Focus | | Mature implementation: AVAudioRecorder, 16kHz resample |
| 7.1.2 | Integrate voice input on all free-text fields | Todo | Deep Focus | | |

### 7.2 — Data Migration
**Status:** Todo
**Priority:** Normal
**Definition of Done:** CBT and DBT app session data migrated accurately with validation.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 7.2.1 | Build migration pipeline (CBT PersistedRun to unified Session) | Todo | Deep Focus | | CBT app actively in use — real data with emotional value |
| 7.2.2 | Build migration pipeline (DBT PersistedRun to unified Session) | Todo | Deep Focus | | Less data than CBT |
| 7.2.3 | Validate migrated data against originals | Todo | Deep Focus | | |
| 7.2.4 | Build minimal historical data viewing UI | Todo | Deep Focus | | Read-only display of migrated protocols and plans |

---

## Phase 8: Alexithymia Path and Onboarding
**Status:** Todo
**Definition of Done:** Body-sensation routing for alexithymia, minimal onboarding orientation. All v1.0 Definition of Done criteria met.

### 8.1 — Alexithymia Path
**Status:** Todo
**Priority:** Normal
**Definition of Done:** "I don't know" on emotion selector routes through body sensations; triage infers emotional state from somatic experience.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 8.1.1 | Build body-sensation routing when emotion is unknown | Todo | Deep Focus | | |
| 8.1.2 | Adapt agent language for alexithymia path | Todo | Deep Focus | | |

### 8.2 — Onboarding
**Status:** Todo
**Priority:** Normal
**Definition of Done:** Minimal orientation explaining what the app does and how to use it.

| # | Task | Status | Effort | Deadline | Notes |
|---|------|--------|--------|----------|-------|
| 8.2.1 | Build minimal onboarding orientation | Todo | Deep Focus | | Not full psychoeducation — enough to make app usable on first launch |

---

## Dependencies

| Item | Depends On | Status |
|------|-----------|--------|
| Phase 2 | Phase 1 (Domain package) | Unmet |
| Phase 3 | Phase 1 + Phase 2 | Unmet |
| Phase 4 | Phase 3 (session flow to integrate into) | Unmet |
| Phase 5 | Phase 3 + Phase 4 | Unmet |
| Phase 6 | Phase 3 + Phase 5 | Unmet |
| Phase 7 | Phase 1 + Phase 3 | Unmet |
| Phase 8 | Phase 5 + Phase 3 | Unmet |

---

## Reference

### Status Values
| Status | Meaning |
|--------|---------|
| Todo | Not yet started |
| In Progress | Actively being worked on |
| Blocked: [reason] | Cannot proceed — reason is one of: poorly-defined, too-large, missing-info, missing-resource, decision-required |
| Waiting | User's part done, waiting on external input |
| Done | Complete |
| Dropped | Deliberately abandoned |

### Effort Types
| Type | Description |
|------|-------------|
| Deep Focus | Sustained concentration, problem-solving, design work |
| Creative | Open-ended, generative, exploratory |
| Administrative | Organising, documenting, updating, filing |
| Communication | Discussions, reviews, feedback |
| Physical | Hands-on work, building, soldering |
| Quick Win | Small, low-effort, momentum-building |

### Priority
High / Normal / Low — milestones only. Tasks inherit from their milestone unless overridden.
