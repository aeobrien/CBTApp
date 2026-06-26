# MentalHealthToolkit — Ledger

> Unified, AI-guided therapeutic toolkit that merges CBT and DBT apps into a single system organised around functional emotional states, not therapeutic modalities.

## Status

**Lane:** personal
**Phase:** Idea / Pre-development
**Last updated:** 2026-04-07

## Subsystems

| Subsystem | Status | Doc |
|-----------|--------|-----|

## Key Decisions

See [decisions/LOG.md](decisions/LOG.md) for the full decision log.

## Linked Projects

| Project | Relationship | Notes |
|---------|-------------|-------|
| MicroJournal | related-to | Companion journaling app shares emotion vocabulary by convention (no runtime integration at v1.0) |

## Open Questions

- How reliably can the AI triage system distinguish between intrusive thoughts, rumination, and examinable beliefs?
- Will the generalised parameteriser handle all 27 techniques with varying step structures?
- What is the actual scope of ViewModel refactoring needed in Phase 1?
- How well does validation-before-change enforcement generalise across all six functional categories?

## Notes

### Summary

MentalHealthToolkit combines two existing apps -- a CBT protocol builder/runner (~/Dev/CBT, actively used) and a DBT skills app (~/Dev/DBT, less data) -- into a single unified system. Rather than organising by therapeutic modality, it routes users to techniques based on six functional categories describing universal emotional states: acute distress, intrusive thoughts, rumination, distorted beliefs, valid emotional pain, and loss of direction.

The AI triage system assesses the user's current state through natural conversation and selects from a curated, evidence-based library of 27 techniques. The system enforces validation-before-change, has a complete safety architecture with two-tier crisis detection, and is designed throughout for ADHD -- low friction, voice-first, no punishment for inconsistency, technique rotation for novelty.

Built as a personal tool by someone who needs it, complementing professional therapy as a practice environment between sessions.

Language: Swift 6, Platform: iOS 17+ (SwiftUI, SwiftData), Priority: P4.

### Architecture

```
App Shell (Entry point, DI container, routing)
  +-- Features (Flows)
  +-- DesignSystem (UI Kit)
  +-- Services (Agent, Voice, Safety, Lib)
  +-- Domain (Models, Enums, Technique Schema, Triage Rules, Safety Rules)
  +-- Data (SwiftData repositories)
  +-- Utilities (Logging, Helpers)
```

MVVM + Coordinator, 6 SPM packages, DI via protocol abstractions.

### Key Technologies

- Swift 6 with strict concurrency
- SwiftUI + @Observable/@Bindable (iOS 17 Observation framework)
- SwiftData (on-device, repository pattern)
- OpenAI GPT API (direct REST, no SDK -- model-agnostic service layer)
- WhisperKit (on-device voice transcription)
- XcodeGen + SPM (6 packages)

### Design Principles

- **Functional, not theoretical** -- organised by what techniques do, not their modality
- **Validation before change** -- always validate experience before suggesting intervention
- **ADHD-aware by design** -- low friction, adaptive, no punishment for inconsistency
- **Safety is structural** -- crisis detection, content policy, and escalation at every layer
- **Curated, not generated** -- AI selects from validated techniques, never invents
- **Complementary** -- supplements professional therapy, actively suggests professional support when needed

### Related Codebases

| Directory | Description |
|-----------|-------------|
| ~/Dev/CBT | Existing CBT app (this repo) -- actively used, has real session data |
| ~/Dev/DBT | Existing DBT app -- less data, UI ready but some backend deferred |

The unified app will be built as a new codebase pulling from both as source material, living in this directory (~/Dev/CBT).
