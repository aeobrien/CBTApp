# Phase 2 Manual Tests — Design System

**Auto-tests passed:** 15/15 (Tokens 3 · TimerModel 9 · OutcomeTag 2 · Module 1)

---

## TC-01: Access Catalogue

1. Run the app. You should see a **"Design System"** section at the top with a **"Component Catalogue"** link.
2. Tap it. You should see a scrollable list titled **"Component Catalogue"** with sections for each component.

**Pass if:** Catalogue opens with all sections visible when scrolling.

---

## TC-02: CBTSlider

1. In the catalogue, find the **"CBTSlider"** section.
2. Drag the "Anxiety Intensity" slider. The number should update smoothly with a numeric animation.
3. The second slider ("No Value Display") should have no value label.

**Pass if:** Slider drags smoothly, value updates with animation, teal accent colour on track.

---

## TC-03: BeliefStrengthSlider

1. Find the **"BeliefStrengthSlider"** section.
2. Drag the slider across the full range.
3. Check that the percentage value updates and the contextual label changes through: "Not at all" → "A little" → "Moderately" → "Strongly" → "Very strongly".
4. 0% and 100% labels should appear below the slider.

**Pass if:** Value, percentage, and contextual label all update correctly.

---

## TC-04: SelectableChip + ChipGrid

1. Find the **"SelectableChip + ChipGrid"** section.
2. You should see two chips at the top: "Selected" (teal background/border) and "Unselected" (plain).
3. Below, a flow-layout grid of emotion chips. "Anxiety" and "Shame" should be pre-selected.
4. Tap chips to toggle selection. They should change between selected (teal) and unselected states.
5. Chips should wrap to new lines as needed.

**Pass if:** Selection toggles visually, flow layout wraps correctly, teal accent on selected chips.

---

## TC-05: OutcomeTagSelector

1. Find the **"OutcomeTagSelector"** section.
2. Should show "What did you notice?" label and a grid of outcome tags.
3. One tag should be pre-selected. Tap others to toggle.

**Pass if:** Tags display with correct labels, selection toggles work.

---

## TC-06: ProtocolCard

1. Find the **"ProtocolCard"** section.
2. Two cards should appear:
   - "Late-Night Rumination" with "Active" badge and "Last used: 2 days ago"
   - "Work Perfectionism" with "Paused" badge and no last-used date
3. Cards should have subtle shadow and rounded corners.

**Pass if:** Both cards render with name, summary, status badge, and optional date.

---

## TC-07: ScriptCard

1. Find the **"ScriptCard"** section.
2. Two script cards should appear:
   - "Thought Defusion" with timer icon and "3m" label
   - "Behavioural Experiment" without timer
3. Cards should have a light teal background tint and border.

**Pass if:** Script text is readable, timer indicator shows where appropriate, teal tint visible.

---

## TC-08: CBTChecklist

1. Find the **"CBTChecklist"** section.
2. Four items should appear. Items 1 and 3 should be pre-checked (filled circle, strikethrough text).
3. Tap unchecked items to check them, and vice versa.

**Pass if:** Checkboxes toggle on tap, strikethrough appears/disappears, touch targets are comfortable.

---

## TC-09: CBTTimer

1. Find the **"CBTTimer"** section.
2. **Countdown timer (3 min)**: Should show "3:00". Tap play to start. Timer counts down. Tap pause to stop. Tap reset to return to 3:00. Progress bar should fill as time elapses.
3. **Count-up timer**: Should show "0:00". Tap play. Timer counts up with no progress bar.

**Pass if:** Both timers start/pause/reset correctly, large readable digits, smooth animation.

---

## TC-10: VoiceInputButton

1. Find the **"VoiceInputButton"** section.
2. Two buttons: "Idle" (teal mic icon) and "Recording" (red stop icon with pulsing animation).
3. The recording button should have a gentle pulsing ring around it.

**Pass if:** Both states display correctly, pulsing animation is visible on the recording button.

---

## TC-11: SafetyBanner

1. Find the **"SafetyBanner"** section.
2. Should show "Need support?" with a heart icon and chevron.
3. Tap to expand — should reveal crisis message and two resources (Samaritans 116 123, Crisis Text Line).
4. Tap again to collapse.

**Pass if:** Expands/collapses with animation, resources display correctly, blue-tinted background.

---

## TC-12: Dark Mode

1. Switch to Dark Mode (Xcode: Features → Toggle Appearance, or device Settings).
2. Scroll through the entire catalogue.
3. All components should remain legible with appropriate colour adaptation.
4. Teal accents, card shadows, chip borders should all adapt.

**Pass if:** All components are legible and visually appropriate in dark mode.
