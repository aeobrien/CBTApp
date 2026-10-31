# Phase 12: Onboarding / Psychoeducation — Manual Test Brief

## Prerequisites
- App builds and runs on iOS Simulator
- Fresh install (delete app first) or use "Reset Onboarding" button

## Test Cases

### 1. Fresh Install Shows Onboarding
1. Delete the app from the simulator
2. Build and run
3. **Expected**: Onboarding welcome screen appears (not ContentView)

### 2. Navigate Through All Screens
1. On Welcome screen, tap "Next"
2. On Hot Thoughts screen, tap each of the 3 example cards to reveal chains
3. Tap "Next"
4. On Maintaining Behaviours screen, tap "Reveal the long-term costs"
5. Tap "Next"
6. On Testing Beliefs screen, tap "Reveal next step" twice to see all 3 steps
7. Tap "Next"
8. **Expected**: Ready screen appears with "Start Workshop" and "Skip for now"

### 3. Back Navigation Works
1. From any screen (not Welcome), tap the back chevron
2. **Expected**: Returns to previous screen with state preserved

### 4. Skip from Welcome
1. On Welcome screen, tap "Skip introduction"
2. **Expected**: Onboarding dismisses, ContentView appears

### 5. Finish from Ready Screen
1. Navigate to Ready screen
2. Tap "Start Workshop"
3. **Expected**: Onboarding dismisses, ContentView appears

### 6. Re-launch Skips Onboarding
1. Complete or skip onboarding
2. Kill and re-launch the app
3. **Expected**: ContentView appears directly (no onboarding)

### 7. Reset Onboarding
1. In ContentView, scroll to "Onboarding" section
2. Tap "Reset Onboarding"
3. Kill and re-launch the app
4. **Expected**: Onboarding appears again
