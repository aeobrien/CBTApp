# Manual Test Brief — Phase 13 + 14: Quick Triage & Settings

## Prerequisites
- App builds and launches on iPhone Simulator
- At least 1 sample protocol visible in Run Mode

---

## Phase 13: Quick Triage

### TC-13-01: Triage Wizard Launch
1. Open Run Mode (Start a Run)
2. On protocol selection, tap "I'm not sure"
3. **Expected**: Triage sheet appears with step 0 (urge selection)

### TC-13-02: Step Navigation
1. In triage wizard, select an urge → tap Next
2. Select a theme → tap Next
3. Adjust intensity slider → tap Next
4. **Expected**: Progress through 4 steps; Back button works on steps 1–2

### TC-13-03: Matching Results
1. Complete all 3 triage questions
2. **Expected**: Result screen shows matched protocols sorted by score, or "No matching protocols" if none match

### TC-13-04: Select Matched Protocol
1. On result screen, tap a matched protocol
2. **Expected**: Triage sheet dismisses, Run Mode starts with that protocol (capture screen)

### TC-13-05: Build New Option
1. On result screen (with or without matches), tap "Build something new instead" or "Build New Protocol"
2. **Expected**: Sheet dismisses

---

## Phase 14: Settings

### TC-14-01: Settings Navigation
1. From main menu, tap Settings
2. **Expected**: Settings form appears with API Key, Data, Protocols, and About sections

### TC-14-02: API Key Save
1. Enter an API key in the secure field
2. Tap "Save Key"
3. **Expected**: "Key saved" confirmation appears

### TC-14-03: Export Protocols
1. Tap "Export Protocols"
2. **Expected**: File exporter dialog appears with JSON file

### TC-14-04: Import Protocols
1. Tap "Import Protocols"
2. Select a valid JSON file (previously exported)
3. **Expected**: "Import successful" message, protocol list updates

### TC-14-05: Import Invalid File
1. Tap "Import Protocols"
2. Select a non-JSON or malformed file
3. **Expected**: Error message shown, no crash

### TC-14-06: Archive Protocol
1. In Protocols section, tap the archive icon on an active protocol
2. **Expected**: Protocol status changes to "Archived"

### TC-14-07: Delete Protocol
1. Tap trash icon on a protocol
2. **Expected**: Confirmation alert appears
3. Confirm deletion
4. **Expected**: Protocol removed from list

### TC-14-08: Reset Onboarding
1. Tap "Reset Onboarding" in About section
2. **Expected**: No crash; restarting app would show onboarding again

---

## Automated Tests Summary

| Package  | Tests | Status |
|----------|-------|--------|
| Domain   | 112   | Pass   |
| Features | 109   | Pass   |
| Data     | 8     | Pass   |
