# Phase 3 Manual Tests — Curated Intervention Library

**Auto-tests passed:** 69/69 (Domain 50 + InterventionLibrary 5 + Parameteriser 7 + Selector 7)

---

## TC-01: Browse Templates

1. Run the app. Tap **"Browse Templates"** under "Intervention Library".
2. You should see **9 templates** listed, each with name, type badge, and indication text.
3. Types should include: Behavioural experiment (×2), Defusion, Graded exposure step, Behavioural activation, Delay experiment, Opposite action, Rumination scheduling, Problem-solving step.

**Pass if:** All 9 templates listed with correct names and type badges.

---

## TC-02: Template Detail

1. Tap **"Prediction Test"** (first template).
2. Check the detail screen shows:
   - Type, duration, and timed status
   - Evidence basis citation
   - Contraindications with warning icons
   - Numbered steps
   - Example scripts in italics

**Pass if:** All sections display with realistic clinical content.

---

## TC-03: Parameterisation — Hot Thought

1. On the Prediction Test detail, scroll to the **"Parameterise"** section.
2. Type a hot thought, e.g. `"everyone thinks I'm stupid"`.
3. Tap **"Generate Script"**.
4. A script card should appear with your hot thought substituted into the text.
5. The character count should show below (e.g. "180/240 chars").

**Pass if:** Hot thought appears in the generated script, within the 240 char limit.

---

## TC-04: Parameterisation — Urge Behaviour

1. Go back and tap **"Urge Delay"** (the delay experiment template).
2. In the parameterise section, type an urge behaviour, e.g. `"scroll through Instagram"`.
3. Tap **"Generate Script"**.
4. The script should include your urge behaviour text.

**Pass if:** Urge behaviour substituted correctly into the script.

---

## TC-05: Parameterisation — Long Input Truncation

1. On any template, enter a very long hot thought (paste a paragraph of text).
2. Tap **"Generate Script"**.
3. The script should be truncated to 240 characters max, ending with "...".
4. The character count should confirm it's at or under 240.

**Pass if:** Script truncated cleanly at a word boundary, ending with "...".

---

## TC-06: Parameterisation — Empty Input

1. On any template, leave all fields empty and tap **"Generate Script"**.
2. The script should appear with "..." replacing the placeholder (no `{{...}}` visible).

**Pass if:** No raw placeholder text visible in the generated script.

---

## TC-07: Different Templates Have Different Content

1. Browse through 3-4 different templates.
2. Check that each has distinct steps, scripts, contraindications, and evidence citations.

**Pass if:** Templates clearly differ in content — not duplicated boilerplate.
