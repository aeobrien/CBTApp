# Phase 5: Run Mode — Manual Test Brief

## Prerequisites
- App builds and launches on simulator
- 3 sample protocols visible (Late-night rumination, Social comparison scrolling, Work perfectionism)

---

## TC-01: Protocol Selection
1. Tap "Start a Run" on the home screen
2. Verify all 3 protocols are shown as cards
3. Type "rumination" in search — only "Late-night rumination" should appear
4. Clear search — all 3 reappear
5. Type "zzzzz" — "No protocols found" message shown
6. **Pass criteria**: Search filters correctly, cards show name + summary + status badge

## TC-02: Full Run Flow
1. Select "Late-night rumination"
2. **Capture screen (B)**:
   - Type a situation: "Lying in bed after a long day"
   - Tap "I should have said something different" hot thought chip
   - Tap Anxiety emotion chip → slider appears at 50, drag to 70
   - Tap Tight chest body signal
   - Tap Ruminate urge
   - Drag belief strength to 80
   - Verify safety banner is visible at the bottom
   - Tap Next
3. **Guided Discovery screen (C)**:
   - Verify "I should have said something different" is displayed
   - Type a prediction: "I'll be up all night"
   - Type an alternative: "This will pass"
   - Tap Next
4. **Intervention screen (D)**:
   - Verify a script card is displayed with title and script text
   - If timed, verify timer appears with play/pause/reset
   - If steps shown, check a few boxes
   - Tap "Try a different intervention" — card should change
   - Tap Next
5. **Outcome screen (E)**:
   - Verify Anxiety slider is pre-populated at 70
   - Drag to 40
   - Drag belief strength to 50
   - Tap "Intensity dropped" outcome tag
   - Type learning note: "The delay exercise helped"
   - Type forward plan: "Use delay technique next time"
   - Tap Next
6. **Summary screen (F)**:
   - Verify summary text contains situation, emotions, belief shifts
   - Tap thumbs up
   - Tap Done
7. **Pass criteria**: Returns to home screen, no crashes throughout

## TC-03: Skip Capture
1. Start a run, select any protocol
2. On Capture screen, tap "Skip"
3. Should jump directly to Intervention screen
4. Complete remaining screens to Summary
5. Tap Done
6. **Pass criteria**: Skip path completes without crash

## TC-04: Skip Guided Discovery
1. Start a run, select any protocol
2. Fill in Capture screen, tap Next
3. On Guided Discovery, tap "Skip"
4. Should jump to Intervention screen
5. Complete remaining screens
6. **Pass criteria**: Skip path completes without crash

## TC-05: Multiple Emotions
1. Start a run, select any protocol
2. On Capture, tap Anxiety + Sadness + Shame
3. Verify 3 sliders appear, one per emotion
4. Adjust each to different values
5. Continue through to Outcome
6. Verify all 3 emotions appear on Outcome screen with pre-populated values
7. **Pass criteria**: Multiple emotion sliders render and persist correctly

## TC-06: Empty State
1. If no protocols exist (all removed), tap "Start a Run"
2. Verify "No protocols found" empty state is shown
3. **Pass criteria**: Graceful empty state, no crash

## TC-07: Timer on Timed Intervention
1. Start a run where a timed intervention is recommended (e.g. delay experiment)
2. On Intervention screen, verify timer is displayed
3. Tap play — timer counts down
4. Tap pause — timer stops
5. Tap reset — timer returns to initial value
6. **Pass criteria**: Timer start/pause/reset work correctly

## TC-08: Intervention Switching
1. On Intervention screen, tap "Try a different intervention"
2. Verify the script card changes to a different intervention
3. Tap again — cycles through available options
4. **Pass criteria**: Intervention changes, checklist resets on switch

---

## Auto-test summary
- Domain: 108 tests (101 existing + 7 new RunSummary tests)
- Features: 23 tests (22 new RunFlowViewModel tests + 1 existing)
- Total new: 29 tests
