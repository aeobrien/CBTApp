# Phase 10: Safety & Escalation System — Manual Test Brief

## Prerequisites
- App builds and launches on iOS Simulator
- Safety Test Harness accessible from main menu

## Test Cases

### 1. Acute Risk in Workshop
1. Open Workshop Test Harness → start new workshop
2. In the Capture stage, type "I want to kill myself" in the situation field
3. Tap Next
4. **Expected**: Full-screen safety modal appears with "Support is available" heading, crisis resources, NO continue button, dismiss disabled

### 2. Elevated Risk with Continue
1. Open Safety Test Harness
2. Tap "Elevated: I'd be better off dead"
3. Tap "Scan Text"
4. **Expected**: Safety modal appears WITH continue button and "I'm safe, close this" dismiss option
5. Tap Continue → modal dismisses

### 3. Acute Risk in Run Mode
1. Start a Run → select a protocol
2. In Capture screen, type "I want to end my life" in the situation field
3. Tap Next
4. **Expected**: Safety modal appears, cannot be dismissed, shows crisis resources

### 4. Benign Text — No False Positive
1. Open Safety Test Harness
2. Tap "Benign: I'm anxious about my exam"
3. Tap "Scan Text"
4. **Expected**: "No risk detected" message, no safety modal

### 5. Metaphorical Language — No False Positive
1. Open Safety Test Harness
2. Tap "Metaphor: I could kill for a coffee"
3. Tap "Scan Text"
4. **Expected**: "No risk detected" message, no safety modal

### 6. PHQ-9 Score Increase
1. Open Safety Test Harness
2. Tap "Test: Score increase +5"
3. **Expected**: Safety modal with chronic non-response message, continue button available

### 7. PHQ-9 Item 9 Suicidality
1. Open Safety Test Harness
2. Tap "Test: Item 9 suicidality"
3. **Expected**: Safety modal with acute risk, NO continue button

### 8. Disengagement Detection
1. Open Safety Test Harness
2. Tap "Test: 20-day gap"
3. **Expected**: Safety modal with disengagement message ("haven't completed a run in 20 days"), continue button available

### 9. Safety Resources Design Review
1. Open Safety Test Harness → "Show Acute Alert"
2. **Review**: Heart icon (not alarm), calm blue background, resource cards with phone/URL links, professional tone
3. Verify Samaritans, Crisis Text Line, NHS Talking Therapies are listed
4. Verify phone numbers are tappable (tel: links)
5. Verify "I'm safe, close this" is disabled for acute alerts

### 10. Workshop sendMessage Safety Hook
1. Open Workshop → start new workshop → advance to Recurrence stage (guided discovery)
2. Type "I feel suicidal" in the chat input
3. Tap Send
4. **Expected**: Safety modal appears BEFORE the message is sent to the agent
