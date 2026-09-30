# Phase 4 Manual Tests — Protocol Engine + JITAI Logic

**Auto-tests passed:** 100/100

---

## TC-01: Access Engine Test Harness

1. Run the app. Tap **"Engine Test Harness"** under "Protocol Engine".
2. You should see sections: Protocol picker, Simulated Conditions, an Evaluate button, and Review Rules.

**Pass if:** Test harness loads with all controls visible.

---

## TC-02: First Run — Default Recommendation

1. Set completed runs to **0**, leave other conditions at defaults.
2. Tap **"Evaluate Engine"**.
3. Should recommend a **behavioural experiment** (Prediction Test or Survey).
4. JITAI Reasoning should mention "First run".

**Pass if:** Behavioural experiment recommended for a first-time user.

---

## TC-03: Measure Due — Highest Priority

1. Toggle **"Measure due"** ON. Leave other settings.
2. Tap **"Evaluate Engine"**.
3. Should show **Action: promptMeasure** — prompting to complete the measure first.

**Pass if:** Measure prompt takes priority over all other recommendations.

---

## TC-04: Active Experiment Follow-Up

1. Toggle "Measure due" OFF, toggle **"Active experiment"** ON.
2. Tap **"Evaluate Engine"**.
3. Should show **Action: followUpExperiment** — prompting to record experiment outcome.

**Pass if:** Experiment follow-up takes priority when no measure is due.

---

## TC-05: Recent Run with Low Intensity

1. Toggle "Active experiment" OFF.
2. Set **last run to 1h ago**, **last run intensity to 20**, completed runs to 3.
3. Tap **"Evaluate Engine"**.
4. Should show **Action: outsideAppAction** — suggesting to try the forward plan outside the app.

**Pass if:** Outside-app action suggested for recent low-intensity runs.

---

## TC-06: Urge-Based Recommendations

1. Set last run to 5h ago (to avoid recency rule). Set completed runs to 3.
2. Select urge: **"Ruminate"**. Tap evaluate. Should recommend rumination scheduling or defusion.
3. Select urge: **"Avoid"**. Tap evaluate. Should recommend graded exposure or behavioural experiment.
4. Select urge: **"Withdraw"**. Tap evaluate. Should recommend opposite action or behavioural activation.

**Pass if:** Each urge type produces a sensible, distinct recommendation.

---

## TC-07: Intensity-Based Recommendations

1. Set urge to **None**. Set completed runs to 5.
2. Set intensity to **15** (low). Evaluate. Should suggest behavioural experiment.
3. Set intensity to **75** (high). Evaluate. Should suggest delay or defusion.
4. Set intensity to **95** (very high). Evaluate. Should prioritise delay experiment.

**Pass if:** Recommendations scale appropriately with intensity.

---

## TC-08: Review Rule Evaluation

1. Set completed runs to **5** or higher.
2. Tap **"Evaluate Review Rules"**.
3. Should show results for each review rule — some triggered (orange warning), some not (green check).
4. Each result shows the rule's action and a reason explaining why it triggered or didn't.

**Pass if:** Review rules display with clear triggered/not-triggered status and reasoning.

---

## TC-09: Switch Between Protocols

1. Change the protocol picker to each of the 3 sample protocols.
2. Re-evaluate after each switch.
3. Recommendations may differ based on each protocol's configuration.

**Pass if:** Engine responds to different protocols without errors.
