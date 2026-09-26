# Revision Instructions: Vision Statement & Technical Brief

## Purpose

This document contains specific, actionable instructions for revising the CBT app's Vision Statement and Technical Brief. Each instruction identifies the gap, explains why it matters (with reference to the research report), and provides a concrete fix. These instructions are derived from two independent critiques and the author's own priorities.

**Governing principle:** Efficacy is the top priority. Do not sacrifice clinically validated components to reduce friction. Where speed and clinical completeness conflict, choose completeness and find other ways to manage cognitive load (e.g., smart defaults, skip options, voice input).

---

# PART A: Vision Statement Revisions

---

## VS-01: Add Collaboration as a Named Design Principle

**Gap:** The vision describes the agent as a "CBT protocol designer" whose job is to clarify, identify, surface, and translate. The user's role is to receive and act on protocols. Collaboration — shared responsibility for building the formulation — is never named.

**Why it matters:** CBT competence frameworks treat collaboration as foundational: shared responsibility for structure/content, agreed agendas, two-way feedback. This is not a stylistic preference; it's a core competence alongside guided discovery.

**Instruction:** Add a new principle (after Principle 3 "Behaviour over explanation" or as a replacement for the current "Role of the agent" section's framing). The principle should state:

- The app builds protocols *with* the user, not *for* them.
- User agency extends to shaping the formulation itself, not just acting on it.
- The agent's role is to scaffold the user's own pattern recognition, not to present finished analyses for approval.

Additionally, revise "The role of the agent" section. Change the framing from "Its responsibilities are to: help the user clarify / identify / surface / translate" to something like: "Its responsibilities are to: ask the questions that help the user clarify / scaffold the user's identification of / guide the user toward surfacing / support the user in translating." The difference is who is doing the cognitive work.

---

## VS-02: Add Guided Discovery as an Explicit Interaction Model

**Gap:** The vision never mentions guided discovery or Socratic questioning. The closest it gets is the tone line "Let's look at what's happening and test something small."

**Why it matters:** The research report identifies guided discovery as a "distinctive in-session stance" with direct design implications — it implies "an interaction style (curious, open, non-hectoring) and an epistemology ('let's test this together') rather than a didactic coaching voice."

**Instruction:** Add a new subsection under "The role of the agent" or as a standalone principle titled something like "Discovery over instruction." It should state:

- The agent uses open, curious questioning to help the user generate their own hypotheses — not persuasion, not lecture, not pre-packaged analysis.
- The agent never tells the user what their pattern is. It asks questions that help the user see the pattern themselves.
- This applies primarily in Workshop mode (where the user has bandwidth for reflection). In Run mode, the user is activated and needs execution support, but even there, a brief moment of self-generated insight (e.g., "What does this thought predict?") should be preserved where possible.

This principle should explicitly name the difference between Workshop mode (guided discovery is essential) and Run mode (guided discovery is compressed but present).

---

## VS-03: Elevate the Review–Learn–Refine Loop to a First-Class Principle

**Gap:** The vision mentions "behavioural learning" and "learn, over time, which beliefs actually need updating." But the systematic cycle — review outcomes, extract learning, refine protocol — is implicit rather than structural.

**Why it matters:** The research report calls homework compliance "one of the most consistently supported process variables in CBT research" and says the review → learn → refine loop "is not a nice-to-have; it is one of the most direct translations of 'what CBT is' into software mechanics."

**Instruction:** Add a new principle (suggest placing it after "Small, testable steps"). Title it something like "Repetition with reflection." It should state:

- The app's value is not only in-the-moment interruption; it is in the systematic accumulation of evidence across repeated cycles.
- Every run generates data. That data feeds a review process. Review leads to protocol refinement. Refinement leads to better runs. This loop is the treatment, not a feature of the treatment.
- The app should prompt review at defined intervals, not leave it to user initiative.

---

## VS-04: Add Measurement-Based Care as a Structural Principle

**Gap:** The vision's Principle 5 ("Data as feedback, not judgement") addresses the *tone* of measurement. It doesn't establish measurement as a *steering mechanism* — something that systematically drives protocol decisions.

**Why it matters:** Both critiques independently flagged this. CBT competence frameworks explicitly require baselines, repeated standardised measures, and progress feedback as part of treatment. NICE's digital therapy guidance uses outcome monitoring to inform stepped-care decisions. The vision currently treats measurement as passive observation; the evidence says it should be active infrastructure.

**Instruction:** Expand Principle 5 or add a companion principle. It should state:

- Measurement is part of the treatment, not a reflection on it.
- The app establishes baselines when a protocol is created, tracks standardised symptom measures periodically (e.g., PHQ-9, GAD-7), and uses pre-defined decision rules to trigger protocol revision, escalation prompts, or completion signals.
- This is distinct from gamification. Standardised measures are clinical tools that inform what happens next — they are not scores, grades, or engagement metrics.
- The vision should explicitly reject the false dichotomy between "measurement as judgement" (which it rightly opposes) and "measurement as clinical infrastructure" (which it currently also excludes by omission).

---

## VS-05: Add a Principle on Human Support and Escalation

**Gap:** The vision says the app is "not a replacement for therapy" but never addresses what happens when the app isn't enough. Both critiques flagged this as the single largest philosophical gap.

**Why it matters:** Guided iCBT outperforms unguided (76% vs 54% adherence; modestly better outcomes, especially at higher severity). The research report recommends a "stepped-support design" and says human support should be treated "as a product feature, not an optional extra." The vision's silence creates an implicit model of total self-sufficiency, which contradicts the evidence base.

**Instruction:** Add a new principle. Title it something like "Honest about its own limits." It should state:

- The app is designed for self-directed use, but it recognises that self-direction has boundaries.
- The app should proactively acknowledge when a pattern may benefit from professional support — not as a failure state, but as a legitimate protocol output and a natural part of the CBT stepped-care model.
- Escalation signals (sustained deterioration, chronic non-response, crisis indicators) should be built into the protocol logic, not handled as edge cases.
- The long-term architecture should support optional human support integration (therapist messaging, coach check-ins), even if the MVP doesn't implement it.

Also add to "The ethical centre" section: if a future feature avoids recommending professional support in order to retain users within the app, it should be rejected — just as features that increase engagement at the expense of agency should be rejected.

---

## VS-06: Add a Curated Intervention Library as a Content Integrity Commitment

**Gap:** The vision says the agent should prioritise "behavioural experiments over reframes" and "simplicity over completeness," but doesn't specify that interventions come from a defined, evidence-based library rather than being generated by the LLM.

**Why it matters:** The research report explicitly recommends constraining the LLM to "assembling protocols from a curated library of evidence-based micro-interventions" and cites Wysa's model of "clinician-created interventive conversations" with AI handling routing, not content creation. This is the single most important safety/fidelity constraint in the report.

**Instruction:** Add to the "Consistency over cleverness" principle (or as a new companion principle):

- The app draws from a defined library of evidence-based intervention templates. The agent selects and parameterises interventions; it does not invent them.
- Each intervention template has: indication boundaries, contraindications, steps, example prompts, and success criteria.
- This mirrors how manualised CBT works in trials and services: defined methods, applied flexibly, but not invented ad hoc.
- The agent's creativity is in *how it helps the user understand and apply* an intervention — not in *what the intervention is*.

---

## VS-07: Add Privacy by Design as an Explicit Principle

**Gap:** Privacy is not mentioned in the vision statement. Both critiques flagged this.

**Why it matters:** The research report cites empirical findings of "unnecessary permissions, insecure implementations, and third-party sharing risks" in popular mental health apps and calls privacy by design "a core product requirement, not a compliance afterthought."

**Instruction:** Add a principle (suggest placing it in or near "The ethical centre" section):

- The app treats all user cognitive and emotional data as sensitive by default.
- Data is stored locally first. Nothing leaves the device without explicit user action.
- The app collects the minimum data necessary for the protocol to function.
- No third-party sharing of any user content, ever.

---

## VS-08: Add Regulatory Awareness to the Ethical Framework

**Gap:** The vision's ethical section focuses on user-facing values. It doesn't acknowledge that the product may operate in a regulated space (MHRA medical device classification, NICE ESF, DTAC).

**Why it matters:** Both critiques flagged this. An app that adapts interventions using health data and makes claims about changing cognitive/behavioural patterns is navigating medical device territory.

**Instruction:** Add a brief paragraph to "The ethical centre" section acknowledging:

- The app's claims, data handling, and adaptive algorithms exist within a regulatory framework.
- Design decisions must be compatible with UK regulatory expectations (MHRA, NICE ESF, DTAC) even if formal certification is not pursued in the first version.
- This constrains feature design: the app cannot make clinical treatment claims without evidence to support them, and its adaptive logic must be auditable.

---

## VS-09: Add Voice Input as an Accessibility and Friction-Reduction Principle

**Gap:** The vision emphasises minimal friction and assumes the user is "not at their best" when they need the app most. But it doesn't mention voice input, which is potentially the lowest-friction input method for a distressed user.

**Instruction:** Add to Principle 1 ("Frictionless in moments of activation"):

- The app should support voice input as a primary interaction method, transcribed locally using an on-device model (e.g., Whisper) to preserve privacy.
- Voice input is not a convenience feature; it is an accessibility requirement. When the user is activated, typing may be the hardest thing to do. Speaking is often easier.
- Local transcription ensures that raw audio never leaves the device.

---

## VS-10: Reframe the "Debugging" Metaphor

**Gap:** The vision frames CBT as a "debugging framework" with the agent as an active participant. This subtly positions the app as the debugger and the user's mind as the system being debugged.

**Why it matters:** CBT's collaborative model says the user is the primary agent. The app is the environment/tooling, not the operator.

**Instruction:** Keep the debugging metaphor if it resonates, but add a clarifying line:

- "The user is the debugger. The app is the debugging environment — it provides structure, visibility, and tools, but the user runs the process."

---

## VS-11: Address Engagement Honestly

**Gap:** The vision correctly rejects engagement-maximisation. But it doesn't address the genuine challenge that most mental health app users stop before they get benefit.

**Instruction:** Add a brief acknowledgement (possibly in "How the app helps over time"):

- The app must deliver recognisable value within the first few uses — not because engagement is a goal, but because a tool that isn't used cannot help.
- The onboarding experience should get the user to a completed run as quickly as possible, so they experience the loop before deciding whether to continue.
- This is not engagement optimisation; it is minimum-effective-dose design.

---

## VS-12: Add a Note on Onboarding and Psychoeducation

**Gap:** The vision assumes the user arrives knowing they have a pattern to work on. It doesn't address the path from "I feel bad" to "I have a pattern I can describe."

**Why it matters:** The research report lists psychoeducation as a standard iCBT component. The technical brief's Quick Triage is a partial answer, but the vision should acknowledge this gap.

**Instruction:** Add a brief note (possibly in "How the app should feel" or as a new subsection):

- The app should help the user develop the *vocabulary* to describe their patterns, not assume they already have it.
- The first Workshop experience should include a lightweight psychoeducation element: what's a maintaining behaviour, what's a hot thought, why do we test rather than argue. This is not content for its own sake — it's the minimum conceptual scaffolding needed for the user to participate in their own formulation.

---

# PART B: Technical Brief Revisions

---

## TB-01: Redesign Workshop Mode Stages to Use Guided Discovery

**Gap:** Workshop stages are a structured interview where the agent proposes and the user selects. This is not guided discovery.

**Instruction:** Revise Workshop stages as follows:

**Stage 1 (Define a single instance):** No major change needed — capturing the raw situation is appropriate.

**Stage 2 (Extract repeatables):** Change from "agent suggests 5 hot-thought templates; user picks" to: agent asks open questions ("When else does something like this show up? What's the thought that keeps coming back?"). Agent reflects and sharpens. User confirms. Agent *then* offers template suggestions only if the user is stuck.

**Stage 3 (Identify maintaining behaviours):** Change from "pick from list" to: agent asks "What do you usually do when this thought shows up? What does that do for you in the short term? What does it cost you?" Agent maps the answers to the maintaining-behaviour taxonomy. User confirms the mapping. The list becomes a fallback, not the primary input method.

**Stage 4 (Pick one target belief/loop):** Change from "agent proposes 2–3 candidates; user selects" to: agent asks "If we could test one thing about this pattern — one prediction your mind is making — what would it be?" Agent helps the user sharpen the belief into something testable. Agent reflects back candidate formulations only after the user has generated their own version.

**Stage 5 (Design interventions):** Agent presents options from the curated intervention library (see TB-05) with brief rationales. User selects. Agent parameterises with user's specific language.

**Stage 6 (Design experiments):** Agent scaffolds: "What would it take to find out if [target belief] is accurate? What could you do this week that would give you evidence either way?" Agent helps shape the answer into a structured experiment.

For all stages: add a note that voice input (see TB-09) is the recommended input method during Workshop, since the user needs to think aloud rather than type precisely.

---

## TB-02: Expand Run Mode to Include Full Micro-Session Structure

**Gap:** Run mode implements Capture → Intervention → Outcome. The research recommends a 5-part micro-session: agenda, guided discovery, action method, homework/practice plan, summary + feedback.

**Design priority:** Efficacy over speed. Do not drop clinically validated components to save time. Manage cognitive load through smart defaults, skip options, and voice input instead.

**Instruction:** Expand the Run mode flow from 4 screens to 6 screens (with skip options on 2 of them):

**Screen A — Start Run (Protocol selection):** No change.

**Screen B — Capture:** No major change. Add voice input option for the situation field.

**Screen C — Brief Guided Discovery (NEW):**
- Show the captured hot thought.
- Ask: "What does this thought predict will happen?" (single-line text or voice input, with common predictions from the protocol as tap-to-select options).
- Ask: "What's an alternative possibility?" (same input method, with protocol-specific alternatives as suggestions).
- This screen is skippable ("Skip to action") but present by default.
- Rationale: this is the cognitive examination step that distinguishes CBT from simple distraction. It takes 30–60 seconds and produces the learning that makes runs accumulate into belief change rather than just emotional regulation.

**Screen D — Do (intervention):** No major change. Ensure intervention is selected from curated library, not generated.

**Screen E — Outcome:** Expand to include:
- Current emotion/belief ratings (existing).
- Outcome tags (existing).
- **New:** "What did you learn from this?" (optional single-line text or voice, with common learning tags: "The prediction didn't happen," "It was uncomfortable but tolerable," "I can handle more than I thought").
- **New:** "One thing to try before the next run:" (optional, single-line, or select from protocol's experiment steps). This is the homework/forward-planning element.

**Screen F — Summary (NEW):**
- Brief auto-generated summary: "You noticed [hot thought], tested [alternative], and found [outcome tag]. Next step: [forward plan]."
- "Was this run helpful?" (thumbs up/down — feeds review data).
- This screen is skippable but present by default.
- This operationalises the summary + feedback component.

Update the success metric: change "Median run completion time ≤ 3 minutes" to "Median run completion time ≤ 5 minutes" to accommodate the additional screens. Note that the 5-minute target still preserves the "doable when activated" constraint while honouring clinical completeness.

---

## TB-03: Add Standardised Measurement Infrastructure

**Gap:** The brief relies entirely on subjective 0–100 sliders. Both critiques flagged the absence of standardised clinical measures.

**Instruction:**

**Add to Protocol JSON spec (Section 5.1):** Add a new optional field:
- `standardised_measures`: array of measure objects, each containing: `measure_id` (e.g., "PHQ-9", "GAD-7"), `frequency` (e.g., "weekly", "fortnightly"), `last_administered`, `scores[]` (timestamped history).

**Add to Workshop Mode:** At protocol creation (Stage 7 or as a new Stage 7.5), the agent should suggest relevant standardised measures based on the pattern type. For example: if the target loop involves low mood/avoidance → suggest PHQ-9. If anxiety/worry → suggest GAD-7. The user confirms or declines.

**Add to Evidence & Review (Section 8):** The protocol dashboard should display standardised measure trends alongside the per-run belief/emotion charts. Weekly review cards should reference standardised scores when available (e.g., "Your PHQ-9 score this week: 12, down from 15 two weeks ago").

**Add to Run Mode:** Standardised measures are NOT administered during runs (this would add too much friction). They are administered as standalone prompts at the frequency specified in the protocol — the app surfaces a brief "time for a check-in" notification and presents the questionnaire outside of any specific run.

**Add baseline capture:** During the first Workshop for a new protocol, after the formulation is complete and before generating JSON, prompt the user to complete the relevant standardised measure. This becomes the baseline against which progress is tracked.

---

## TB-04: Add Escalation and Stepped-Care Logic

**Gap:** Safety gating handles acute crisis signals. There is no logic for chronic non-response or gradual deterioration.

**Instruction:**

**Add to Protocol JSON spec:** Add a new field:
- `escalation_rules`: array of rule objects, each containing: `trigger` (e.g., "PHQ-9 increase ≥ 5 points over 2 administrations", "no completed runs in 14 days", "3+ protocols with no improvement"), `action` (e.g., "show escalation prompt", "suggest professional support", "pause protocol and show review").

**Add to the protocol engine (Section 11.2):** Add escalation rule evaluation as a scheduled check (e.g., after each standardised measure administration, or weekly). When triggered, the app should:
- Show a calm, non-alarmist message acknowledging that this pattern may benefit from professional support.
- Provide relevant resources (therapist directories, GP referral info, NHS self-referral for Talking Therapies).
- Frame this as part of the CBT model (stepped care), not as an app failure.
- Allow the user to acknowledge and continue, or to pause the protocol.

**Add to Section 12 (Edge Cases):** Add a new subsection "12.5 — User is deteriorating" describing this flow.

**Add to Section 10.1 (Safety Gating):** Distinguish between:
- **Acute risk detection** (existing: crisis signals → resources screen → stop protocol generation).
- **Chronic non-response detection** (new: sustained lack of improvement or worsening → escalation prompt → professional support recommendation).
- **Disengagement detection** (new: prolonged absence → gentle re-engagement prompt with option to archive protocol or seek support).

---

## TB-05: Define the Curated Intervention Library as a First-Class System Component

**Gap:** The brief has the agent "write scripts" for interventions. The relationship between built-in templates and agent-generated content is unclear.

**Instruction:**

**Add a new section (suggest Section 5.5 or a new Section 13) titled "Intervention Library."** It should specify:

- The app maintains a curated library of evidence-based intervention templates.
- Each template contains: `intervention_id`, `type` (e.g., "behavioural_experiment", "defusion", "graded_exposure_step", "behavioural_activation", "delay_experiment", "opposite_action", "rumination_scheduling", "problem_solving_step"), `indication` (when to use), `contraindications` (when not to use), `steps` (ordered list), `example_scripts` (parameterised text templates), `duration_estimate`, `success_criteria`, `evidence_basis` (brief citation or rationale).
- The agent's role in Workshop Stage 5 is to: select appropriate templates based on the formulation, parameterise them with the user's specific language and context (e.g., inserting the user's hot thought into a defusion script template), and present them for user selection. The agent does NOT generate novel intervention types.
- Scripts generated by the agent must stay within the template's structure. The agent may adapt language and examples but may not alter the intervention's core mechanism.

**Update Section 4.3 (LLM integration contract):** Add an explicit constraint: "The agent may customise intervention scripts within template boundaries but may not invent new intervention types or mechanisms. All interventions in a generated protocol must reference a valid `intervention_id` from the library."

**Update Workshop Stage 5:** Change "write scripts that are neutral, non-arguing, self-compassionate" to "select and parameterise intervention templates from the curated library. Scripts must be neutral, non-arguing, and self-compassionate."

---

## TB-06: Expand the Formulation Model in the Protocol JSON

**Gap:** The Protocol JSON captures triggers, hot thoughts, maintaining behaviours, target belief, and interventions as separate lists. It doesn't capture the *linked chain* the report recommends: triggers → appraisals → emotions/physiology → behaviours → short-term relief → long-term costs.

**Instruction:**

**Add to Protocol JSON spec (Section 5.1):** Add a new required field:
- `formulation`: object containing:
  - `trigger_appraisal_links[]`: array of objects mapping `trigger` → `appraisal` (hot thought) → `emotion` → `behaviour`.
  - `maintaining_cycles[]`: array of objects, each containing: `behaviour`, `short_term_function` (what relief it provides), `long_term_cost` (what it maintains or worsens), `target_intervention_id` (which intervention addresses this).

This structure makes the formulation a *coherent model* rather than a collection of independent fields. It enables: better agent reasoning during protocol revision (the agent can see *why* each intervention was chosen), clearer user understanding of the maintaining cycle, and the "conceptual integration" that the research report identifies as a fidelity marker.

**Update Workshop Mode:** The formulation object should be progressively built across Stages 1–4, with the agent reflecting the emerging chain back to the user at each stage ("So when [trigger] happens, you think [appraisal], which makes you feel [emotion], and then you [behaviour] because it gives you [short-term relief], but the cost is [long-term cost]. Does that capture it?").

---

## TB-07: Add Relapse Prevention / Protocol Completion Pathway

**Gap:** The brief describes protocol creation, execution, review, and revision. It doesn't describe what happens when a protocol succeeds.

**Instruction:**

**Add to Section 8 (Evidence & Review):** Add a subsection "8.3 — Protocol Completion." When review data shows sustained improvement (e.g., belief strength consistently below a threshold, standardised measure in remission range, user self-report of reduced pattern activation), the app should:

1. Prompt the user to summarise what they learned ("What do you know now that you didn't before?"). This captures the generalised skill.
2. Generate a brief "if this returns" relapse-prevention card: a minimal protocol containing the key trigger, the updated belief, and the one intervention that worked best. This card lives in a "Completed" section of the protocol library.
3. Track completed protocols separately from archived ones — completion is a positive outcome; archiving is neutral.

**Add to Protocol JSON spec:** Add a `status` enum: `active`, `paused`, `completed`, `archived`. Add an optional `completion_summary` field and an optional `relapse_prevention_card` object.

---

## TB-08: Justify and Bound ACT Integration

**Gap:** Section 1.1 includes "ACT-style defusion as a permitted technique" with no specification of when, why, or with what constraints.

**Instruction:** Add a note (in the intervention library section, see TB-05) that specifies:

- ACT-style defusion is included as a specific intervention type within the curated library.
- Its indication boundary is: when the maintaining behaviour is rumination or thought-action fusion, and the thought content is not readily testable through behavioural experiment (e.g., existential or identity-level thoughts where "testing the prediction" doesn't apply cleanly).
- It is not a separate therapeutic modality — it is a technique borrowed from ACT and applied within the CBT formulation framework.
- The agent should not default to defusion when a behavioural experiment is feasible. Defusion is a secondary option when direct testing isn't practical.

---

## TB-09: Add Voice Input Specification

**Gap:** Neither document mentions voice input, despite the vision's emphasis on minimal friction for distressed users.

**Instruction:**

**Add to Section 4.1 (High-level components), under Client App:** Add "on-device speech-to-text engine (e.g., Whisper) for voice input transcription."

**Add to Section 4.2 (Data flow principles):** Add: "Voice input is transcribed locally using an on-device model. Raw audio is never stored, transmitted, or sent to any external service. Only the resulting text enters the data pipeline."

**Add to Section 9.2 (Components):** Add a voice input component: "Microphone button available on all free-text fields. Tap to speak; transcription appears in real-time. User can edit before confirming."

**Update Run Mode (Section 7.1):** Note voice input as the recommended input method for situation descriptions and optional notes. In the new Screen C (guided discovery), voice input should be the primary suggested method since the user is thinking aloud.

**Update Workshop Mode (Section 6.1):** Note voice input as the primary suggested input method for all stages, since the user needs to think aloud rather than compose precise text.

**Add to Section 11 (Technical implementation):** Add a subsection "11.5 — Voice input pipeline" specifying: on-device Whisper model (specify size: suggest `whisper-small` or `whisper-base` for latency; `whisper-medium` if accuracy is prioritised), real-time transcription, no audio persistence, text post-processing (punctuation, basic cleanup).

---

## TB-10: Add Engagement / Minimum-Effective-Dose Metrics

**Gap:** Success metrics are all within-user and assume sustained use. They don't address the reality that most mental health app users drop off before getting benefit.

**Instruction:**

**Add to Section 2.2 (Secondary success metrics):**
- Time-to-first-completed-run (target: within first session of app use).
- 7-day and 30-day return rates (tracked, not optimised — these are diagnostic, not targets).
- "Minimum effective dose" identification: what is the fewest number of runs at which users begin to show belief-strength shifts? Design onboarding to get users past this threshold.

**Add to Section 2.3 (Anti-metrics):**
- Optimising for return-rate at the expense of clinical integrity is a failure mode. These metrics inform design; they do not drive it.

---

## TB-11: Expand Privacy Specification

**Gap:** Section 10.2 covers privacy defaults but doesn't specify what data goes to the LLM, server-side retention, or third-party sharing commitments.

**Instruction:**

**Expand Section 10.2 to include:**
- An explicit enumeration of what fields are sent to the agent service (structured fields only; free text only when user initiates Workshop or revision; never the full run history or protocol library unless user explicitly exports).
- A server-side data retention policy: agent service should not retain user content after the session ends. If content is logged for safety monitoring, specify retention period and access controls.
- An explicit "no third-party sharing of any user content" commitment — no analytics partners, no advertising, no research sharing without explicit opt-in consent.
- Voice data policy: raw audio is never stored or transmitted; only transcribed text enters the pipeline (cross-reference TB-09).

---

## TB-12: Add Regulatory Compliance Section

**Gap:** The brief doesn't address UK regulatory requirements for an AI-driven health tool.

**Instruction:**

**Add a new section (suggest Section 14 or expand Section 10) titled "Regulatory and Governance Considerations."** It should state:

- An app that uses an LLM to adapt interventions based on health data may be classified as a medical device by the MHRA, depending on intended purpose and claims made.
- The product should be designed to be compatible with: NICE's Evidence Standards Framework (ESF) for digital health technologies, and NHS England's Digital Technology Assessment Criteria (DTAC).
- Specific design implications: adaptive algorithms must be auditable (the curated intervention library + deterministic protocol engine support this); claims must be evidence-based (avoid clinical treatment claims without supporting RCT evidence); data handling must comply with UK GDPR.
- This section should be reviewed with legal/regulatory counsel before any public release or NHS engagement.

---

## TB-13: Operationalise JITAI Framework

**Gap:** The report recommends a JITAI (Just-In-Time Adaptive Intervention) lens. The brief's protocol recommendation engine (Section 11.2) has three rules. This should be a more systematic framework.

**Instruction:**

**Expand Section 11.2 (Protocol engine):** Rename the recommendation rules to "JITAI adaptation logic" and expand to include:

- **Contextual signals considered:** time of day, day of week, recency of last run, recent run outcomes (improving/stable/worsening), current emotional intensity (if captured via check-in), active experiment status.
- **Adaptation types:** which protocol to suggest, which intervention within a protocol to recommend, whether to suggest a full run or a micro-intervention, whether to prompt a review instead of a run.
- **Decision logic:** specify as a rules table or decision tree. For example:
  - If last run was <2 hours ago and intensity was low → suggest "try acting outside the app" instead of another run.
  - If active experiment is in progress → prompt experiment follow-up instead of a new run.
  - If time matches a known high-activation period (from historical run data) → proactively suggest the relevant protocol.
  - If standardised measure due → prompt measure before run.

---

## TB-14: Add Onboarding / Psychoeducation Flow

**Gap:** The brief assumes the user arrives ready to describe a pattern. It doesn't address the path from "I feel bad" to "I have a pattern I can articulate."

**Instruction:**

**Add a new section (suggest Section 6.0 or a preamble to Section 6) titled "First Use / Onboarding."** It should specify:

- On first launch, before the first Workshop, the app provides a brief (~2 minute) interactive psychoeducation sequence.
- Content covers: what's a hot thought (with examples), what's a maintaining behaviour (with examples), why we test rather than argue, what a protocol is and how it helps.
- This is not a content library or a course. It's the minimum conceptual scaffolding needed for the user to participate in their own formulation.
- The sequence ends by launching the first Workshop with the framing: "Let's try this with something real."
- This can be skippable for users who already understand the model (e.g., those with therapy experience).

---

# PART C: Items Considered and Not Included

## Cultural Sensitivity
Both critiques noted the absence of cultural adaptation considerations. However, the author has confirmed this app is designed for a single user. This concern is therefore not applicable and should not be added to either document.

## Sacrificing Completeness for Speed
The second LLM's critique was more cautious about the tension between frictionless design and clinical completeness, sometimes suggesting that trade-offs were acceptable. The author has explicitly stated that efficacy is the top priority. All recommendations above honour this: where speed and completeness conflict, completeness wins, with cognitive load managed through smart defaults, skip options, and voice input rather than by dropping clinical components.
