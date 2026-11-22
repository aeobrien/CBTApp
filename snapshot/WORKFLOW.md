# Development Workflow: CBT App

## How We Work Together

This document defines the exact process for building each module. It ensures consistency, minimises rework, and keeps both of us efficient.

---

## The Module Cycle

Every module follows this 5-step cycle. No step is skipped.

### Step 1: Spec (I write, you review)

Before writing any code, I produce a brief spec for the module:

- **What it does** (one paragraph)
- **Inputs and outputs** (data types, protocols)
- **Dependencies** (which existing modules it uses)
- **Contract** (how other modules will interact with it)
- **Edge cases** (known tricky scenarios)

You review and confirm, or flag anything that feels wrong. This is your chance to course-correct before code is written.

### Step 2: Build (I write code)

I implement the module following project conventions:

- Code goes in the correct SPM package/layer
- All public interfaces get logging at `.info` level
- All decision points get logging at `.debug` level
- All errors get logging at `.error` level with full context
- SwiftUI views get Previews with mock data
- ViewModels are `@Observable` classes conforming to testable protocols

### Step 3: Auto-Test (I write and run tests)

I write comprehensive tests and run them before you see anything:

- **Unit tests** for every public method
- **Edge case tests** for boundary conditions, empty states, maximum values
- **Integration tests** where the module touches persistence or other modules
- All tests must pass. If they don't, I fix issues and re-run.

You'll see the test results in my output. If all pass, we move to Step 4.

### Step 4: Manual Test Brief (I write, you execute)

I provide you with a structured test document:

```
## Manual Test: [Module Name]

### Setup
[Exact steps to get the test view running — which scheme, which simulator/device]

### Test Cases

#### TC-01: [Name]
1. [Step 1 — exact action to take]
2. [Step 2]
3. **Expected**: [What you should see]
4. **Log check**: Filter console by category "[X]" and look for [Y]

#### TC-02: [Name]
...

### How to Report Issues
- Describe what happened vs what was expected
- Paste the relevant console logs (filter by subsystem "com.cbt.app" and category "[module]")
- Screenshot if it's a visual issue
```

### Step 5: Your Feedback → Fix → Commit

You run the manual tests and report back:
- **Pass**: Everything worked as expected → I commit to the module branch
- **Issue**: Something didn't work → you paste logs + description → I diagnose and fix → re-run auto-tests → provide updated manual test if needed
- **Feel wrong**: It works technically but doesn't feel right → you describe the issue → I adjust

Only after both testing tiers pass do I merge to `main`.

---

## Session Management

### Starting a session

At the start of each coding session, I will:
1. Check the ROADMAP.md for the current phase
2. Read the relevant CLAUDE.md files
3. Check git status for any in-progress work
4. State what I'm going to work on before starting

### Ending a session

Before ending or if context is getting long:
1. Commit any passing work
2. Update the ROADMAP.md with progress notes
3. Write a session summary to `docs/session-log.md` noting what was done, what's next, and any open issues

### Context refresh

If we need to start a fresh conversation:
1. I read CLAUDE.md, ROADMAP.md, and the latest session log
2. I check git log and status
3. I resume from where we left off

---

## Debugging Protocol

When something goes wrong during your testing:

### What to capture

1. **What you did**: The exact steps (reference the test case number)
2. **What happened**: What you saw (screenshot if visual)
3. **What you expected**: Reference the test case's "Expected" line
4. **Console logs**:
   - In Xcode, filter the console by subsystem `com.cbt.app`
   - Optionally filter by category (the module name) to narrow down
   - Copy the relevant log lines
   - Paste them to me

### What I do with it

1. Read the logs to identify where the flow diverged from expected behaviour
2. Trace the correlation ID through related log entries
3. Identify the root cause
4. Fix + re-run auto-tests
5. Confirm the fix addresses your specific scenario
6. Provide updated manual test if the fix changed behaviour

### Log levels explained

- **Debug** (grey in console): Flow tracing — "entered function X", "chose path Y because Z". These are verbose and help me trace exactly what happened.
- **Info** (default): State changes — "protocol loaded", "run saved", "intervention selected". These tell me what the app did.
- **Error** (yellow/red): Something failed — "validation failed: missing field X", "API call failed: timeout". These tell me what went wrong.

---

## Branch Strategy

```
main                          ← stable, tested code only
├── phase-0/scaffolding       ← merged after Phase 0 complete
├── phase-1/domain-models     ← merged after Phase 1 complete
├── phase-2/design-system     ← merged after Phase 2 complete
└── ...
```

Each phase gets one branch. Within a phase, I commit incrementally as sub-modules pass auto-tests. The branch merges to `main` only after all sub-modules pass both auto-tests and your manual tests.

---

## File Organisation

```
CBTApp/
├── CLAUDE.md                          ← project-wide conventions
├── ROADMAP.md                         ← this roadmap
├── WORKFLOW.md                        ← this document
├── CBTApp/                            ← main app target
│   ├── CBTApp.swift                   ← app entry point
│   ├── AppCoordinator.swift           ← root navigation coordinator
│   └── ContentView.swift
├── Packages/
│   ├── Domain/                        ← entities, protocols, enums
│   │   ├── Sources/Domain/
│   │   └── Tests/DomainTests/
│   ├── Data/                          ← SwiftData persistence
│   │   ├── Sources/Data/
│   │   └── Tests/DataTests/
│   ├── Services/                      ← agent, validation, safety
│   │   ├── Sources/Services/
│   │   └── Tests/ServicesTests/
│   ├── DesignSystem/                  ← UI components
│   │   ├── Sources/DesignSystem/
│   │   └── Tests/DesignSystemTests/
│   ├── Features/                      ← feature modules
│   │   ├── Sources/Features/
│   │   │   ├── RunMode/
│   │   │   ├── Workshop/
│   │   │   ├── Evidence/
│   │   │   ├── Onboarding/
│   │   │   ├── QuickTriage/
│   │   │   └── Settings/
│   │   └── Tests/FeaturesTests/
│   └── Utilities/                     ← logging, extensions
│       ├── Sources/Utilities/
│       └── Tests/UtilitiesTests/
├── docs/
│   ├── session-log.md                 ← progress tracking
│   └── manual-tests/                  ← manual test briefs per module
└── TestFixtures/                      ← shared mock data, sample JSON
```

---

## Quality Gates

A module is "done" when:

- [ ] All auto-tests pass (unit + integration + edge cases)
- [ ] Logging is instrumented at all decision points
- [ ] SwiftUI Previews work with mock data
- [ ] Manual test brief provided
- [ ] Manual tests passed by you
- [ ] No known issues or TODOs in the module code
- [ ] Code committed to phase branch

A phase is "done" when:

- [ ] All modules in the phase are "done"
- [ ] Phase branch merged to `main`
- [ ] ROADMAP.md updated with completion status
- [ ] Session log updated
