# Manual Test: Phase 0 — Scaffolding

## Setup

1. Open `/Users/aidan/Dev/CBT/CBTApp.xcodeproj` in Xcode
2. Select the **CBTApp** scheme (top-left dropdown)
3. Select **iPhone 16** simulator as the destination
4. Wait for Xcode to finish resolving packages (you should see 6 packages in the Project Navigator under "Package Dependencies")

## Test Cases

### TC-01: App builds and launches

1. Press `Cmd+R` to build and run
2. **Expected**: The app launches in the simulator showing:
   - A navigation bar titled "CBT App"
   - A brain icon
   - Text "CBT Protocol Builder"
   - Text "Phase 0 — Scaffolding Complete"
   - A blue "Test Logging" button

### TC-02: Logging works

1. With the app running, open Xcode's console (View → Debug Area → Activate Console, or `Cmd+Shift+Y`)
2. In the console filter bar, type `com.cbt.app` to filter by subsystem
3. **Expected**: You should see log entries including:
   - `App launched` (from app init)
   - `ContentView appeared` (from view appearing)
4. Now tap the **"Test Logging"** button in the app
5. **Expected**: Four new log entries appear in the console, each with a correlation ID (a short hex string in square brackets):
   - A debug message: `[xxxxxxxx] Debug: flow trace test`
   - An info message: `[xxxxxxxx] Info: state change test`
   - A warning message: `[xxxxxxxx] Warning: recoverable issue test`
   - An error message: `[xxxxxxxx] Error: failure test`
6. All four should share the same correlation ID (the text in brackets)

### TC-03: Log filtering by category

1. In the console filter bar, change the filter to `App` (the category name)
2. **Expected**: Only logs from the App category should appear
3. Clear the filter and try `RunMode` — **Expected**: No results (we haven't logged from that category yet)

### TC-04: Tests run in Xcode

1. Press `Cmd+U` to run tests
2. **Expected**: The test navigator shows 3 passing tests:
   - `testUtilitiesPackageAccessible`
   - `testDomainPackageAccessible`
   - `testLoggerCreation`

### TC-05: Dark mode

1. On the simulator, go to Settings → Developer → Dark Appearance (or Settings → Display & Brightness → Dark)
2. Switch back to the CBT app
3. **Expected**: The app renders correctly in dark mode (no unreadable text, background adapts)

## How to Report Issues

- Describe what happened vs what was expected (reference the TC number)
- For logging issues: paste the console output (filter by `com.cbt.app` first)
- For visual issues: take a screenshot (`Cmd+S` in Simulator)
