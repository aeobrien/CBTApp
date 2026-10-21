# Phase 9: Workshop Mode — Manual Test Brief

## Prerequisites
- App builds and launches on iOS Simulator
- ContentView shows "Workshop Test Harness" link

## Test Steps

### 1. New Protocol Workshop
1. Tap "Workshop Test Harness" → "Start Workshop"
2. **Stage 1 (Capture)**:
   - Enter a situation (e.g. "About to present at work")
   - Enter a hot thought (e.g. "I'm going to mess this up")
   - Select an emotion (e.g. Anxiety)
   - Adjust intensity slider
   - Select an urge (e.g. Avoid)
   - Tap "Next" → should advance to Stage 2
   - Verify: "Next" disabled when situation is empty

3. **Stage 2 (Recurrence)**:
   - Agent should auto-send opening message
   - Type responses to agent questions (2+ exchanges)
   - Verify: typing indicator shows while agent responds
   - Tap "Next" → should advance to Stage 3

4. **Stage 3 (Maintaining)**:
   - Agent asks about maintaining behaviours
   - After 2+ exchanges, behaviour picker appears
   - Add at least one maintaining behaviour
   - Verify: can remove behaviours with X button
   - Tap "Next" → should advance to Stage 4

5. **Stage 4 (Target Belief)**:
   - Agent uses Socratic questioning
   - After 2+ exchanges, belief text field appears
   - Edit/confirm the target belief
   - Verify: formulation view shows trigger → belief → emotion → urge chain
   - Tap "Next" → should advance to Stage 5

6. **Stage 5 (Interventions)**:
   - Browse available intervention cards
   - Tap to select at least one intervention (checkmark appears)
   - Tap again to deselect
   - Verify: "Next" disabled with no selection
   - Select one or more → tap "Next"

7. **Stage 6 (Experiment Design)**:
   - Agent helps design experiment
   - After conversation, tap "Structure the experiment"
   - Fill in prediction, steps, success criteria
   - Can add more steps with "Add Step" button
   - Tap "Next"

8. **Stage 7 (Capture Fields)**:
   - Toggle capture fields on/off
   - Defaults should be pre-selected
   - Tap "Next"

9. **Stage 7.5 (Measures)**:
   - Toggle PHQ-9 and/or GAD-7
   - If enabled, select frequency (weekly/fortnightly/monthly)
   - Tap "Next"

10. **Stage 8 (Review Rules)**:
    - Default rules shown
    - Can delete rules by swiping
    - "Reset to Defaults" button works
    - Tap "Next"

11. **Stage 9 (Generate)**:
    - "Generate Protocol" button visible
    - Tap to generate → progress spinner shown
    - On success: protocol summary card with name, summary, intervention count
    - Tap "Done" → dismisses workshop

### 2. Back Navigation
1. Start a new workshop
2. Advance to Stage 3
3. Tap "Back" → should return to Stage 2
4. Verify: Stage 2 conversation history preserved
5. Go back to Stage 1 → situation and emotion still filled
6. Re-advance through stages → data preserved

### 3. Revision Mode
1. Tap "Revise Sample Protocol"
2. Verify: Stage 1 pre-filled with protocol data (situation, emotion, urge)
3. Verify: hot thought pre-filled
4. Verify: can modify and advance through all stages
5. Verify: Stage 9 shows "Revise Protocol" instead of "Generate Protocol"

### 4. Progress Bar
1. Verify: progress bar visible at bottom across all stages
2. Current stage highlighted, completed stages filled
3. Stage numbers match (1, 2, 3, 4, 5, 6, 7, 7.5, 8, 9)

## Expected Test Counts
- Domain: existing (142) + new FormulationBuilder (10) + WorkshopPrompts (6) = ~158
- Features: existing (49) + new WorkshopFlowVM (28) = ~77
