# Phase 6: Validation Pipeline — Manual Test Brief

## Prerequisites
- App builds and launches on iOS Simulator

## Test Steps

### 1. Navigate to Validation Test Harness
- Launch the app
- Tap **"Validation Test Harness"** in the Validation Pipeline section
- **Expected**: Screen appears with multiple sections

### 2. Sample Protocols Section
- Check each of the 3 sample protocols
- **Expected**: Each shows errors (orange field paths + messages) because sample data uses non-library intervention IDs like `"delay_01"` rather than real library IDs like `"delay-experiment-urge"`
- Errors should include `invalidReference` on `interventions[N].interventionID`

### 3. Invalid: Empty Name
- **Expected**: Red X icon, error on `"name"` field with `missingRequired`

### 4. Invalid: No Interventions
- **Expected**: Error on `"interventions"` field with `missingRequired`

### 5. Invalid: Script Too Long
- **Expected**: Error on `"interventions[0].script"` with `constraintViolation`

### 6. Invalid: Content Policy
- **Expected**: Error on `"interventions[0].script"` with `contentPolicy` message about medical language

### 7. Error Detail Display
- For each invalid section, verify:
  - Field path is shown in orange
  - Error message is shown in grey
  - Error count is displayed

## Pass Criteria
- All sections render without crashes
- Valid protocols show green checkmark (or expected reference errors for sample data)
- Invalid protocols show red X with correct error details
- Scrolling is smooth, no layout issues
