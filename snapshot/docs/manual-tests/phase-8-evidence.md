# Phase 8: Evidence & Review — Manual Test Brief

## Prerequisites
- App builds and runs on iOS Simulator
- Phase 7 committed (Agent Service)

## Test Steps

### 1. Dashboard
1. Tap **Evidence & Review > Evidence Test Harness** from the main menu
2. The Dashboard tab loads automatically
3. **Verify**:
   - Stats summary shows run count, avg emotion change, helpfulness %, avg duration
   - Belief strength chart displays with Before (orange) and After (blue) lines
   - Outcomes bar chart shows tag frequencies
   - GAD-7 measure section shows latest score and severity band
   - "Administer" button is present next to GAD-7
   - "Weekly Review" button is visible
   - If completion criteria met: "Complete Protocol" button appears in green

### 2. Weekly Review
1. Tap the **Review** tab (or "Weekly Review" button on Dashboard)
2. **Verify**:
   - Insight cards appear with icons and descriptions
   - Cards are sorted by priority (most important first)
   - If a consistency streak exists (3+ runs this week), it shows
   - If worsening outcomes, a "Revise Protocol" button appears

### 3. Measure Administration (PHQ-9)
1. Tap the **Measures** tab
2. Tap **Patient Health Questionnaire-9**
3. **Verify**:
   - Progress bar shows at top
   - One question displayed per screen
   - 4 response options shown (Not at all, Several days, More than half the days, Nearly every day)
4. Answer all 9 questions
5. **Verify**:
   - Result screen shows total score and severity band
   - Score comparison with previous score shown (if available)
   - "Save & Close" button works

### 4. Measure Administration (GAD-7)
1. Tap **Generalised Anxiety Disorder-7** from Measures tab
2. Answer all 7 questions
3. **Verify**: Score and severity band displayed correctly

### 5. Protocol Completion
1. Return to Dashboard tab
2. If "Complete Protocol" button visible, tap it
3. **Verify**:
   - Candidate info shown ("Ready to complete" with reason)
   - Learning note text field is editable
   - Pre-filled relapse prevention card shows trigger, belief, best intervention
4. Type a learning note and tap "Complete Protocol"
5. **Verify**:
   - Confirmation view shows with completed relapse prevention card
   - "Done" button dismisses the view

### 6. Navigation
1. Back button on each screen returns to previous
2. Tabs switch correctly between Dashboard, Review, and Measures
3. Sheets (measure admin, completion) dismiss properly

## Pass Criteria
- [ ] Dashboard loads with stats, charts, and measures
- [ ] Weekly review generates insight cards
- [ ] PHQ-9 questionnaire completes with correct scoring
- [ ] GAD-7 questionnaire completes with correct scoring
- [ ] Protocol completion flow works end-to-end
- [ ] No crashes or layout issues
