# Phase 15 — Integration, Polish, Full Flow Manual Tests

## Prerequisites
- App freshly installed (delete from simulator/device first) to test first-launch flow
- API key configured (for Workshop LLM generation)
- Physical device preferred (for Whisper voice input)

---

## Scenario 1: First Launch — Onboarding → Workshop → Home

1. Launch app on fresh install
2. **Expect**: Onboarding flow appears (5 screens: Welcome, Hot Thoughts, Behaviours, Testing, Ready)
3. Tap through all onboarding screens
4. **Expect**: Workshop fullScreenCover appears after onboarding completes
5. Complete or dismiss the Workshop
6. **Expect**: HomeView appears with seeded sample protocols (Late-Night Rumination, Comparison Scrolling, Work Perfectionism)
7. Force-quit and relaunch
8. **Expect**: HomeView appears directly (no onboarding, no Workshop)

**Pass criteria**: Onboarding → Workshop → Home on first launch; Home directly on subsequent launches.

---

## Scenario 2: Protocol List & Navigation

1. From HomeView, verify 3 sample protocols are listed under "Your Protocols"
2. Each row shows: name, summary, run count (if any), last run date (if any)
3. Tap a protocol row
4. **Expect**: ProtocolDetailView with Dashboard content
5. Verify bottom toolbar: Run, Weekly Review, Revise buttons
6. Tap back to HomeView
7. Swipe left on a protocol row → Archive action
8. **Expect**: Protocol disappears from list
9. Pull to refresh → list reloads

**Pass criteria**: Navigation to/from detail works; archive removes from list; refresh works.

---

## Scenario 3: Build New Protocol via Workshop

1. From HomeView, tap "Build New Protocol"
2. **Expect**: Workshop fullScreenCover appears
3. Complete Workshop stages or cancel
4. If completed with LLM generation: new protocol appears in HomeView list on dismiss
5. Tap the new protocol → Dashboard shows 0 runs

**Pass criteria**: Workshop creates protocol that persists in SwiftData and appears in HomeView.

---

## Scenario 4: Run a Protocol End-to-End

1. From HomeView, tap "Start a Run"
2. **Expect**: RunFlowCoordinator appears (fullScreenCover)
3. Select a protocol from the list
4. Complete all steps: Capture → Guided Discovery → Intervention → Outcome → Summary
5. Dismiss run flow
6. **Expect**: HomeView refreshes; protocol row shows updated run count
7. Tap into protocol → Dashboard shows stats for the completed run
8. Verify: completed run count incremented, belief strength trend has data

**Pass criteria**: Run data persists to SwiftData; Dashboard reflects completed run.

---

## Scenario 5: Quick Triage → Run

1. From HomeView, tap "I'm Not Sure"
2. **Expect**: QuickTriage sheet appears
3. Complete all 4 steps: urge → theme → intensity → results
4. **Expect**: Matching protocols shown with scores
5. Tap a matched protocol
6. **Expect**: Sheet dismisses; RunFlowCoordinator opens with selected protocol context
7. If no matches: "Build New Protocol" button should open Workshop

**Pass criteria**: Triage finds protocols from SwiftData; selecting one transitions to Run.

---

## Scenario 6: Evidence & Completion Flow

1. Run a protocol 3+ times (can use the same protocol repeatedly)
2. Navigate to the protocol's ProtocolDetailView
3. Dashboard should show: completed count, emotion change, belief trend
4. Tap "Weekly Review" in toolbar
5. **Expect**: WeeklyReviewView with insight cards
6. Go back, then if protocol shows completion candidate banner, tap to complete
7. **Expect**: ProtocolCompletionView with learning note and relapse prevention card
8. Complete the protocol
9. **Expect**: Protocol status changes; may disappear from active list

**Pass criteria**: Evidence views show real data; completion flow works end-to-end.

---

## Bonus Checks

- **Settings**: Gear icon → SettingsView with API key, protocol management, export/import
- **Debug Menu**: (DEBUG builds only) Ant icon in top-left → all test harnesses accessible
- **Safety Banner**: Visible on HomeView; tappable to expand crisis contacts
- **Voice Input**: Works in Run and Workshop (physical device only)
- **Accessibility**: Enable VoiceOver; verify all DesignSystem components read sensibly
- **Dynamic Type**: Change text size in Settings → verify layout doesn't break
