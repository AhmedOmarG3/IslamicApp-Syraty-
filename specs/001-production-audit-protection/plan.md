# Implementation Plan: Production Audit and Protection

**Branch**: `not-created` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-production-audit-protection/spec.md`

## Summary

Create a production-protection baseline before feature implementation. Inventory compatibility contracts, offline religious content, prayer-data behavior, user-owned changes, accessibility states, and release evidence. Work remains divided into small approved task groups; this plan authorizes no code implementation.

## Technical Context

**Language/Version**: Dart/Flutter, using repository SDK constraints

**Primary Dependencies**: Existing Flutter, Cubit, GoRouter, Dio, SharedPreferences, ScreenUtil, and local JSON assets; no new dependency authorized

**Storage**: SharedPreferences for existing Quran progress, bundled Quran/Azkar JSON, remote prayer data

**Testing**: Flutter unit, Cubit, widget, and integration tests plus formatting and static analysis

**Target Platform**: Existing supported platforms, prioritizing Android production users and small-screen Arabic RTL behavior

**Project Type**: Mobile application with offline content and network-dependent prayer information

**Performance Goals**: Measure the existing startup/core-journey baseline before selecting thresholds; allow zero critical crash, data loss, or blocked core journey

**Constraints**: Preserve identity, routes, arguments, assets, keys, religious text, and user edits; disclose prayer freshness/failure; avoid whole-app rewrites

**Scale/Scope**: Live app with 100+ Google Play users; production-protection stage only

## Constitution Check

*GATE: Passed before research and after design.*

- **Existing users**: PASS — compatibility inventory, upgrade fixtures, rollback gates, and user-edit preservation are explicit.
- **Religious content**: PASS — approved baselines and integrity checks are required; no generated content is planned.
- **Arabic accessibility**: PASS — RTL, 200% text, small screens, shared design language, and 48x48 targets are covered.
- **Offline and failures**: PASS — offline Quran/Azkar and qualified prayer states are defined.
- **Incremental testing**: PASS — small task groups and proportionate automated/manual gates are required.
- **Simplicity**: PASS — existing dependencies and feature structure are retained.
- **Ownership**: PASS — Ahmed selects implementation tasks and approves release/religious decisions.

`AGENTS.md` and several durable docs are staged for deletion. This plan does not restore or modify them; agent-context updating is deferred until Ahmed resolves that workspace state.

## Project Structure

### Documentation (this feature)

```text
specs/001-production-audit-protection/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── compatibility-contract.md
│   ├── religious-content-integrity.md
│   ├── prayer-data-states.md
│   └── release-evidence.md
└── checklists/requirements.md
```

### Source Code (repository root)

```text
lib/app/router/                 # Existing route contracts
lib/app/di/                     # Existing dependency wiring
lib/core/constants/             # Keys and asset paths
lib/core/errors/                # Failure taxonomy
lib/features/home/              # Daily states and controls
lib/features/prayer/            # Remote data and freshness
lib/features/quran/             # Offline content and progress
lib/features/azkar/             # Offline content integrity
lib/features/tasbeeh/           # Session-only boundary
lib/features/splash/            # Startup behavior
assets/json/                    # Approved religious source files
test/                           # Protection tests
android/ and ios/               # Identity and release checks
pubspec.yaml                    # SDK, dependencies, assets
```

**Structure Decision**: Keep the current feature-first layout. Add only narrowly scoped tests, failure/state definitions, or documentation required by selected tasks; do not reorganize the app during this stage.

## Complexity Tracking

No constitution violations require justification.

