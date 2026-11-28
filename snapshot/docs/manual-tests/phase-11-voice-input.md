# Phase 11: Voice Input — Manual Test Brief

## Prerequisites
- Physical iOS device (microphone not available on Simulator)
- Network connection for initial model download (~145MB base model)

## Test Cases

### 1. Model Download on First Mic Tap
1. Open Voice Test Harness from home screen
2. Tap the microphone button on the empty field
3. **Expected**: Permission prompt appears (first time), then model downloads
4. **Verify**: Status shows "Ready" after download completes

### 2. Record + Transcribe in Run Mode
1. Start a Run → select any protocol → Capture screen
2. Tap mic button next to "What's happening?" field
3. Speak a sentence clearly (e.g. "I was sitting at my desk feeling overwhelmed")
4. Tap the stop button
5. **Expected**: Edit sheet appears with transcribed text
6. Tap "Insert"
7. **Verify**: Text appears in the situation field, capitalised with period

### 3. Edit Before Confirm
1. Record a sentence in any voice-enabled field
2. In the edit sheet, modify the transcription text
3. Tap "Insert"
4. **Verify**: Modified text is inserted, not the original

### 4. Cancel Transcription
1. Record a sentence
2. In the edit sheet, tap "Cancel"
3. **Verify**: Text field remains unchanged, sheet dismissed

### 5. Append Mode (Non-Empty Field)
1. Type "I was at work" into a text field
2. Tap mic, speak "and feeling stressed"
3. Confirm the transcription
4. **Verify**: Field reads "I was at work and feeling stressed." (lowercase 'a', space-separated)

### 6. Permission Denied Handling
1. Go to iOS Settings → CBT → disable Microphone
2. Return to app, tap a mic button
3. **Expected**: Alert appears saying microphone access required
4. Tap "Open Settings"
5. **Verify**: Taken to app settings page

### 7. Voice Input in Workshop Chat
1. Start Workshop → reach a guided discovery stage (Stage 2 or 4)
2. Use mic button next to the chat input field
3. Speak a message, confirm insertion
4. **Verify**: Text appears in chat input, can be sent normally

### 8. Multiple Consecutive Recordings
1. Record and insert text into field A
2. Immediately record and insert into field B on the same screen
3. **Verify**: Both fields have correct transcriptions, no state leakage
