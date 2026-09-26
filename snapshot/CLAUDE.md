# CBT App — Project Conventions

## Overview
A personal CBT protocol builder + runner iOS app. Turns recurring mental patterns into structured protocols via an agent-led workshop, then supports fast, low-friction "run mode" for in-the-moment use. Built on evidence-based CBT principles with guided discovery, behavioural experiments, and measurement-based care.

## Architecture
- **Pattern**: MVVM + Coordinator
- **Modularisation**: Swift Package Manager, layered packages
- **UI**: SwiftUI with `@Observable` (Observation framework, iOS 17+)
- **Data**: SwiftData
- **LLM**: OpenAI GPT-5.2 via API
- **Voice**: On-device Whisper model
- **Target**: iOS 17+, Xcode 16.x, Swift 6

## Package Layers (dependency flows downward)
```
Features (RunMode, Workshop, Evidence, Onboarding, QuickTriage, Settings)
    ↓
Services (AgentService, ValidationPipeline, SafetySystem)
    ↓
DesignSystem (UI components, tokens)
    ↓
Data (SwiftData repositories)
    ↓
Domain (entities, protocols, enums — NO dependencies)
    ↓
Utilities (logging, extensions — NO dependencies)
```

## Build & Test Commands
```bash
# Build
xcodebuild -scheme CBTApp -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all tests
xcodebuild test -scheme CBTApp -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific package tests
xcodebuild test -scheme Domain -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Code Style

### ViewModels
- `@Observable` classes, never structs
- Conform to a testable protocol defined in Domain
- Inject dependencies via init (protocol types, not concrete)
- Example: see first ViewModel created in Phase 1

### Views
- Every View must have a Preview using mock data
- One primary action per screen
- No business logic in Views — delegate to ViewModel

### Logging
- Use `os.Logger` via the `CBTLogger` utility, NEVER `print()`
- Subsystem: `com.cbt.app`
- Category: module name (e.g., `ProtocolEngine`, `RunMode`, `AgentService`)
- `.debug` for flow tracing (entering functions, choosing branches)
- `.info` for state changes (protocol loaded, run saved)
- `.error` for failures (with full context: input values, error description)
- Include correlation IDs for Runs and Workshop sessions

### Testing
- XCTest for all unit and integration tests
- Every public method gets a test
- Edge cases: empty arrays, boundary values (0, 100), max-length strings, nil optionals
- Mock dependencies via protocol conformance
- Tests must pass before committing

### Data Models
- Domain entities are plain Swift types (structs/enums)
- SwiftData `@Model` classes live in the Data layer and map to/from Domain types
- All enums use controlled string raw values for JSON compatibility
- Protocol JSON validation constraints: scripts ≤ 240 chars, when_to_use ≤ 80 chars

### Naming
- Files: PascalCase matching the primary type (e.g., `CBTProtocol.swift`)
- Protocols: suffix with `Protocol` (e.g., `ProtocolRepositoryProtocol`)
- Mock implementations: prefix with `Mock` (e.g., `MockProtocolRepository`)
- Test files: suffix with `Tests` (e.g., `CBTProtocolTests.swift`)

## Key Files
- `ROADMAP.md` — development phases and module breakdown
- `WORKFLOW.md` — the exact build/test/feedback cycle
- `docs/session-log.md` — progress tracking across sessions
- `docs/manual-tests/` — manual test briefs for each module

## Mistakes to Avoid
<!-- Add entries here as issues arise during development -->
