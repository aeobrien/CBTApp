# MentalHealthToolkit — Vision Statement

## Intent

MentalHealthToolkit is a unified, AI-guided therapeutic toolkit that meets the user where they are in any given moment and draws from the most appropriate evidence-based techniques — regardless of which therapeutic tradition they originate from — to provide practical, immediate support.

The toolkit merges two existing apps (a CBT app and a DBT app, both built by the developer and sharing identical technical foundations) into a single system organised around what the user needs, not which school of therapy invented the technique. A person in acute distress, caught in a rumination loop, or sitting with valid grief should be able to open one app, describe what's happening, and be guided to the right tool — without needing to know or care whether that tool is "CBT" or "DBT" or "ACT."

The system is built around six functional categories that describe universal emotional states (acute distress, intrusive thoughts, rumination, distorted beliefs, valid emotional pain, and loss of direction). These states are relevant regardless of the user's underlying diagnosis or presenting problem. The AI agent assesses the user's current state through natural conversation and selects techniques from a curated, evidence-based library. The user experiences a single coherent system that feels like talking to a well-informed, practically-minded supporter with a deep bench of techniques and the judgment to know which ones fit the moment.

## Motivation

This project exists because real psychological problems don't respect the boundaries between therapeutic modalities. The developer built the CBT app as a panic response to a mental health crisis, then started a DBT app after learning DBT may be more effective for neurodivergent people, and within 48 hours realised the real question was "which tool when?" rather than "which modality?" A person dealing with prolonged grief may need grounding skills one hour, cognitive restructuring the next, and permission to simply sit with pain an hour after that. Forcing them to choose between apps — or between modalities — adds friction and cognitive load at exactly the moments when those resources are most depleted.

The developer has ADHD and builds personal tools as part of a broader wellbeing stack. This is not a speculative project — it's a practical tool intended for daily use, built by someone who needs it. The design priorities (minimal friction, voice-first input, no punishment for inconsistency, varied technique rotation to prevent staleness) emerge directly from lived experience with executive dysfunction and emotional dysregulation. The toolkit is one element alongside exercise, sleep, nutrition, therapy, social connection, and journaling. It doesn't need to be transformative on its own. It needs to be a well-designed contribution that compounds with everything else.

## Audience

The primary user is the developer. The system is designed for one person's needs, though those needs are broadly representative of a wider population: people dealing with multi-layered emotional difficulties who would benefit from integrative therapeutic support, particularly neurodivergent users whose needs are poorly served by single-modality apps.

The design assumes a user who is already engaged in professional therapy and uses the toolkit as a practice environment between sessions — a place to apply and rehearse skills, generate data about what's working, and build autonomous coping capacity over time. The system should recognise when a problem exceeds its scope and actively suggest professional support.

ADHD-specific needs shape the design throughout: low-friction entry points (minimal taps to begin, voice-first interaction), adaptive session length, energy-level adaptation, alexithymia-aware paths (body-sensation routing when the user cannot identify emotions), technique rotation to maintain novelty, and no punishment for irregular use or incomplete sessions.

## Scope

### In scope for v1.0

- Merge of existing CBT and DBT codebases into a single unified app (one repository, shared SPM package structure, unified data layer)
- Data-driven technique library (JSON/config, not compiled enums) containing all 27 existing techniques from both apps, tagged by functional category, energy demand, indications, and contraindications
- AI triage system: user describes their state via voice or text, the agent assesses functional category, selects a technique, and guides the user through it — with fluid course-correction when the initial assessment is wrong
- Unified session flow: Capture → Triage → Validate & Orient → Guide → Outcome & Commit → Summary
- Quick path: minimal 3-screen flow for low-capacity moments
- Structural enforcement of validation-before-change across all interactions
- Complete safety architecture: two-tier crisis detection, configurable safety plan, escalation rules, content policy enforcement, always-accessible crisis resources
- Generalised daily check-in (adapted from DBT diary card concept)
- Voice input throughout (using existing WhisperKit on-device transcription)
- Data migration from both existing apps (CBT app is actively in use; DBT app has less data)
- Alexithymia path: body-sensation-based routing when the user cannot identify emotions
- Minimal onboarding orientation (not a full psychoeducation module)

### v1.0 category maturity

All six functional categories are routed to and functional at v1.0, but they are not equally well-stocked. Categories 1 (Grounding) and 4 (Examining Beliefs) are the strongest, with purpose-built techniques from both existing apps. Categories 2 (Intrusive Thoughts) and 3 (Rumination) are adequate but will benefit from the ACT defusion variants and RFCBT techniques planned for v1.x. Categories 5 (Sitting with Difficult Emotions) and 6 (Values and Forward Movement) are the thinnest — served by adjacent techniques repurposed from DBT's general emotion regulation and mindfulness modules (Radical Acceptance, Wise Mind, Behavioural Activation, Build Mastery) rather than by purpose-built tools. The experience in these categories will be adequate but not as rich or targeted. "Works across all six categories" means the triage system routes correctly and offers reasonable support, not that every category delivers an equally polished experience.

### v1.x additions (post-v1.0, incremental)

New techniques added as self-contained library entries requiring no architectural changes. Prioritised by category thinness:

- **First priority (Categories 5 and 6):** Self-Compassion Break, Compassionate Letter, Common Humanity Reflection, ACT Acceptance and Willingness, ACT Values Clarification, ACT Committed Action Planning, Values-Consistent Goal Setting, Grief-Specific Meaning-Making, Meaning Reconstruction
- **Second priority (Categories 2 and 3):** Imagery Rescripting, ACT Defusion variants (Naming the Story, Leaves on a Stream, Thanking Your Mind, Passengers on the Bus, Silly Voice), RFCBT Abstract-to-Concrete Shift, RFCBT Functional Analysis of Rumination, Behavioural Activation as Pattern Interrupt
- **Low urgency (Categories 1 and 4):** Cognitive Distortion Identification (psychoeducational). These categories are already well-served.

### Explicitly out of scope for v1.0

- Workshop (multi-stage AI-guided protocol/plan building) — the triage system replaces the need for a pre-built plan for the core experience loop
- Formulation building (CBT) and Chain Analysis building (DBT) — Workshop-adjacent features not needed for the core loop
- Unified Plan abstraction — CBTProtocol and SkillsPlan coexist as separate entity types; premature unification deferred
- Standardised measures UI (PHQ-9 etc.) — data structures exist in both apps but no complete UI; escalation works on simpler signals for v1.0
- Cross-system integration with the companion journaling app — the toolkit is self-contained at v1.0; actual data sharing, pattern surfacing, and escalation paths are deferred. However, a shared emotion vocabulary is defined now so both projects use the same constrained emotion list from the start, preserving future integration compatibility without requiring cross-system architecture at v1.0.
- Notification or reminder system — purely on-demand use
- Technique prerequisites and skill gating — not needed until higher-intensity techniques (imagery rescripting) are added
- Full psychoeducation onboarding

## Design Principles

**Functional, not theoretical.** Techniques are organised by what they do for the user, not by which school of therapy they belong to. The user never needs to know whether a technique is CBT or ACT. Modality tags exist in the data layer for provenance and research integrity but are not surfaced in the user experience.

**Evidence-based without being academic.** Every technique in the library must have empirical support. The AI agent selects from a curated library of pre-defined, validated techniques — it cannot invent new ones. This is a hard constraint. But the implementation should feel human, accessible, and practical, not like reading a textbook or filling out a clinical form.

**Validation before change.** Every interaction validates the user's experience before suggesting any intervention. The user should always feel heard before being guided. This is enforced structurally in the AI agent's response patterns, not left to prompt adherence.

**ADHD-aware by design.** The system accounts for executive dysfunction, novelty-seeking, emotional dysregulation, alexithymia, and difficulty with sustained routine. This means varied technique rotation, low-friction entry points, adaptive session length, energy-level adaptation, alexithymia-aware paths, no punishment for inconsistency, and quick paths for low-capacity moments.

**Agency-preserving.** The user chooses when to engage. The system supports intentional, timeboxed practice and actively fosters skill internalisation over time, reducing dependency on the app. The goal is autonomous coping capacity.

**Complementary, not replacing.** This is a practice environment that supplements professional therapy. It is most valuable as a bridge between therapy sessions. The system recognises when a problem exceeds its scope and actively suggests professional support.

**Safety is structural.** Safety is not an add-on feature. Crisis detection, content policy, escalation rules, and scope limitations are woven into every layer — the AI agent's constraints, the session flow, the data model, and the UI.

**Adaptable over time.** The user's problems will change. The functional-category architecture ensures the system remains useful as presenting issues shift. The technique library is extensible, and the triage system adapts its recommendations based on evolving user data.

## Definition of Done

v1.0 is complete when all of the following are true:

1. A single unified app exists, built from the merged CBT and DBT codebases, with one repository and the shared SPM package structure.
2. The technique library is data-driven (JSON/config) and contains all 27 existing techniques with complete metadata: functional category assignments, energy demand ratings, indication keywords, contraindications, placeholder tokens, and step structures.
3. A user can open the app, describe their current state via voice or text, and be guided through an appropriate technique selected by the AI triage system. The triage system makes a reasonable first-pass assessment of functional category and course-corrects fluidly when wrong.
4. The triage system routes to all six functional categories based on the user's described state.
5. The full session flow is implemented: Capture → Triage → Validate & Orient → Guide → Outcome & Commit → Summary.
6. The quick path is implemented: 3-screen minimal flow (quick capture → technique → quick outcome).
7. Validation-before-change is structurally enforced in all AI agent interactions.
8. The safety architecture is complete: two-tier crisis detection (acute blocking, elevated warning), configurable safety plan, pattern-based escalation rules, content policy enforcement in both system prompt and code-level validation, always-accessible crisis resources.
9. The daily check-in is implemented and captures: emotions with intensity, body sensations, strongest urge with intensity, target behaviours, techniques used, overall distress, and optional free-text/voice note.
10. Voice input works on all free-text fields via on-device WhisperKit transcription, with raw audio discarded immediately after transcription.
11. Session history from the existing CBT app (and any DBT app data) is migrated into the unified data layer.
12. The alexithymia path routes through body sensations when the user cannot identify emotions.
13. A minimal onboarding orientation explains what the app does and how to use it.

## Mental Model

The toolkit is an integrative therapist's toolkit in app form. A skilled integrative therapist doesn't think "I'm a CBT therapist" or "I'm a DBT therapist" — they assess what the person in front of them needs right now and reach for the best tool, regardless of which tradition it comes from. They validate before they intervene. They adjust when something isn't landing. They know when a problem is beyond their scope. That's what this system does, with the AI agent playing the role of the therapist's clinical judgment and the technique library playing the role of the therapist's training.

The six functional categories are the therapist's internal assessment framework — "this person needs grounding right now" or "this person needs help examining a belief" — and the techniques are the specific interventions the therapist would reach for once they've made that assessment.

## Ethical Considerations

**Clinical safety as a hard constraint.** The system must never cause harm through inappropriate technique selection, failure to detect crisis states, or overstepping its scope. Safety architecture is not optional and is not deferred — it ships complete in v1.0.

**Not a therapist replacement.** The system consistently frames itself as complementary to professional therapy. It does not diagnose, prescribe, or make clinical claims. It actively suggests professional support when patterns indicate need.

**Curated, not generated.** The AI agent selects from validated techniques; it cannot invent therapeutic interventions. This constraint exists to prevent the system from offering unvalidated or potentially harmful guidance, regardless of how plausible it might sound.

**Privacy by design.** All data is stored locally on-device. The AI agent receives summaries and aggregates, never full session transcripts or raw diary data. Voice recordings are discarded immediately after transcription. No cloud sync in v1.0. The user controls what data leaves the device (via optional export for sharing with their therapist).

**No coercion or guilt.** The system never shames, guilt-trips, or expresses disappointment about missed sessions, irregular use, or incomplete exercises. Inconsistency is normal, not a failure. This is an ethical commitment in its own right — it also happens to align with ADHD-aware design, but it would be the right principle regardless.

**Informed consent for intensive techniques.** Techniques that carry higher emotional risk (such as imagery rescripting, when added in v1.x) require explicit user consent and include grounding/stabilisation resources as fallback. The system checks capacity before offering high-intensity work.
