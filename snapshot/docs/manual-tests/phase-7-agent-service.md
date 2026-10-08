# Phase 7: Agent Service — Manual Test Brief

## Prerequisites
- A valid OpenAI API key with GPT-4o access
- App running on iOS Simulator (iPhone 16)

## Test Steps

### 1. Navigate to Agent Test Harness
- Launch the app
- Scroll to the "Agent Service" section
- Tap "Agent Test Harness"
- **Expected**: The agent test view appears with API key field, workshop message text editor, and a "Generate Protocol" button

### 2. Generate a Protocol
- Paste your OpenAI API key into the secure field
- Leave the default workshop message or type a custom one (e.g., "I have anxiety about making mistakes at work")
- Tap "Generate Protocol"
- **Expected**: A loading spinner appears, then after a few seconds the result section shows:
  - "SUCCESS" with protocol name, version, summary, intervention count, experiment count, and when-to-use triggers
  - The protocol should be contextually relevant to the workshop message

### 3. Verify Protocol Quality
- Check that the generated protocol:
  - Has a meaningful name related to the workshop input
  - Has at least 1 intervention with a valid library ID
  - Has at least 1 experiment
  - Has safety information populated
  - Has whenToUse entries ≤ 80 chars each
  - Has intervention scripts ≤ 240 chars each

### 4. Test Error Handling
- Clear the API key field and tap "Generate Protocol"
- **Expected**: Button is disabled (greyed out)
- Enter an invalid API key (e.g., "bad-key") and tap "Generate Protocol"
- **Expected**: "NETWORK ERROR" or error message displayed

### 5. Console Logging
- Open Xcode's debug console
- Filter by "AgentService"
- **Expected**: Debug and info logs visible with `[AgentService]` prefix, including:
  - "sendChatCompletion" with message count
  - Token usage (prompt + completion + total)
  - "Generation succeeded" or error details

## Pass Criteria
- [ ] Agent test harness accessible from ContentView
- [ ] Protocol generation succeeds with valid API key
- [ ] Generated protocol passes validation (no repair needed = ideal; repair succeeds = acceptable)
- [ ] Error handling works for missing/invalid API key
- [ ] Console logs show structured AgentService entries
