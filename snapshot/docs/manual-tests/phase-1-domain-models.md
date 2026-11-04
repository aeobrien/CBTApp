# Phase 1 Manual Tests — Domain Models + Persistence

**Auto-tests passed:** 65/65 (Utilities 7 · Domain 50 · Data 8)

---

## TC-01: Sample Protocol List

1. Run the app in Simulator or on device.
2. You should see **"CBT App"** as the nav title with a list showing **3 protocols** under "Sample Protocols":
   - **Late-Night Rumination Protocol**
   - **Comparison & Scrolling Protocol**
   - **Work Perfectionism Protocol**
3. Each row shows the protocol **name** (headline font) and a **summary** (caption, secondary colour, max 2 lines).

**Pass if:** All 3 protocols appear with name and summary text.

---

## TC-02: Protocol Detail — Basic Info

1. Tap **"Late-Night Rumination Protocol"**.
2. You should see an inline nav title and a list with sections.
3. Under **"Basic Info"** check:
   - Name: `Late-Night Rumination Protocol`
   - Version: `1.0`
   - Status: `Active`

**Pass if:** All three fields display correct values.

---

## TC-03: Protocol Detail — Triggers & Hot Thoughts

1. Still on the Late-Night Rumination detail screen.
2. **"Triggers"** section should show items like "lying in bed unable to sleep", "replaying a conversation", etc.
3. **"Hot Thoughts"** section should show italicised thoughts like "I should have said something different", etc.

**Pass if:** Triggers and hot thoughts are visible and match realistic CBT content.

---

## TC-04: Protocol Detail — Target & Maintaining Behaviours

1. **"Target"** section should show:
   - Belief: a core belief string
   - Loop: a loop type (e.g. "Rumination")
2. **"Maintaining Behaviours"** section should list behaviours, each showing:
   - A behaviour type name (medium weight)
   - "Relief:" line (caption, secondary)
   - "Cost:" line (caption, red-tinted)

**Pass if:** Target belief/loop display. Behaviours show type, relief, and cost text.

---

## TC-05: Protocol Detail — Interventions

1. **"Interventions"** section should show intervention cards with:
   - Title (medium weight)
   - Script text (caption, secondary)
   - Bottom row: intervention type, duration in minutes, timer icon if timed

**Pass if:** At least one intervention displays with all fields visible.

---

## TC-06: Protocol Detail — Experiments & Safety

1. **"Experiments"** section should show:
   - "Prediction:" text
   - "Steps:" with arrows between steps
   - "Success:" criteria in green-tinted text
2. **"Safety"** section should show:
   - A safety message
   - Resources: Samaritans (116 123), Crisis Text Line (SHOUT to 85258), NHS Talking Therapies

**Pass if:** Experiment fields display. Safety resources show correct names and details.

---

## TC-07: Navigate Between Protocols

1. Go back to the list and tap each of the other 2 protocols.
2. Verify each one loads a detail screen with populated sections.
3. Check that each protocol has **different content** (different triggers, interventions, etc.).

**Pass if:** All 3 protocols navigate correctly and show distinct content.

---

## TC-08: Logging on Appear

1. In the Xcode debug console, look for a log line containing `[app]` when ContentView first appears.
2. It should mention the number of sample protocols loaded (e.g. "3 sample protocols loaded").

**Pass if:** The `[app]` log line appears with protocol count.

---

## TC-09: Dark Mode

1. Switch the Simulator/device to Dark Mode (Settings → Display & Brightness → Dark, or Xcode: Features → Toggle Appearance).
2. Navigate through the protocol list and a detail screen.
3. Check that text is readable, secondary colours adapt, and the red "Cost:" text is still visible.

**Pass if:** All text is legible and colours adapt appropriately in dark mode.
