# Tasks: Production Audit and Protection

**Input**: Design documents from `specs/001-production-audit-protection/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

## Phase 1: Setup (Audit Baseline)

**Purpose**: Capture the current production surface without changing user-owned code.

- [ ] T001 Record the current Git status, staged diff, unstaged diff, package identity, supported platforms, dependency list, and asset declarations in `specs/001-production-audit-protection/baseline.md`
- [ ] T002 [P] Inventory all current routes and valid route-argument shapes from `lib/app/router/app_router.dart` into `specs/001-production-audit-protection/contracts/compatibility-contract.md`
- [ ] T003 [P] Inventory persisted keys, asset paths, and local source assets from `lib/core/constants/app_constants.dart`, `lib/core/constants/assets.dart`, `lib/core/constants/app_assets.dart`, and `pubspec.yaml` into `specs/001-production-audit-protection/contracts/compatibility-contract.md`
- [ ] T004 [P] Record existing test coverage and quality-gate commands in `specs/001-production-audit-protection/baseline.md` without modifying `test/widget_test.dart`

## Phase 2: Foundational (Blocking Protection Contracts)

**Purpose**: Establish shared evidence and test seams before any user-story implementation.

- [ ] T005 Create an audit-finding register with severity, evidence, affected scope, acceptance evidence, disposition, release blocker, and rollback relevance in `specs/001-production-audit-protection/audit-findings.md`
- [ ] T006 [P] Capture approved Quran and Azkar asset fingerprints and structural validation rules in `specs/001-production-audit-protection/contracts/religious-content-integrity.md`
- [ ] T007 [P] Define release-evidence fields and staged-rollout/rollback gates in `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T008 [P] Define representative clean-install, upgrade, offline, small-screen, RTL, and 200%-text fixtures in `specs/001-production-audit-protection/quickstart.md`
- [ ] T009 Add shared test helpers and fixtures for `SharedPreferences`, asset loading, controlled time, and network responses under `test/support/` without changing production behavior
- [ ] T010 Verify the foundational artifacts contain no unresolved placeholders and map each FR-001–FR-034 to at least one task or evidence record in `specs/001-production-audit-protection/traceability.md`

**Checkpoint**: Protection contracts, baseline evidence, and test seams are ready; no production behavior has changed.

## Phase 3: User Story 1 — Upgrade Without Losing Trust or Progress (Priority: P1) — MVP

**Goal**: Preserve existing users’ routes, Quran progress, offline content, assets, and app identity across a protected release.

**Independent Test**: Run clean-install and upgrade fixtures with valid, missing, boundary, and invalid `last_read_index`; exercise all current routes and offline Quran/Azkar journeys; verify no data loss, crash, or protected-contract change.

### Tests for User Story 1

- [ ] T011 [P] [US1] Add persistence compatibility tests for valid, missing, boundary, and invalid `last_read_index` values in `test/features/quran/quran_progress_compatibility_test.dart`
- [ ] T012 [P] [US1] Add route-contract tests for startup, core routes, valid detail arguments, and malformed detail arguments in `test/app/router/app_router_contract_test.dart`
- [ ] T013 [P] [US1] Add Quran and Azkar offline asset availability/parseability tests in `test/features/offline_content_integrity_test.dart`
- [ ] T014 [P] [US1] Add upgrade/clean-install evidence tests and fixtures for persisted values in `test/compatibility/upgrade_compatibility_test.dart`

### Implementation for User Story 1

- [ ] T015 [US1] Make Quran progress recovery preserve `last_read_index` and safely handle absent/out-of-range values in `lib/features/quran/presentation/cubit/quran_cubit.dart`
- [ ] T016 [US1] Make malformed `/surah-details` and `/zekr-details` route extras resolve to a recoverable user journey in `lib/app/router/app_router.dart`
- [ ] T017 [US1] Add approved Quran/Azkar asset integrity validation used by tests without altering `assets/json/quran.json` or `assets/json/adhkar.json` in `test/support/religious_content_validator.dart`
- [ ] T018 [US1] Document package identity, signing, asset-path, and storage-key release checks in `specs/001-production-audit-protection/contracts/compatibility-contract.md`

**Checkpoint**: User Story 1 is independently testable and suitable as the first protected increment.

## Phase 4: User Story 2 — Receive Honest Daily Information (Priority: P1)

**Goal**: Make prayer and home information real, qualified, recoverable, and honest across loading, current, stale, offline, invalid, and failed states.

**Independent Test**: Exercise the complete prayer state matrix and home surface with controlled network/time/location inputs; verify visible Arabic states, provenance, no fixed demo values, and recovery actions.

### Tests for User Story 2

- [ ] T019 [P] [US2] Add prayer data-source tests for success, timeout, offline, non-success response, malformed response, and typed failure behavior in `test/features/prayer/prayer_remote_data_source_test.dart`
- [ ] T020 [P] [US2] Add prayer state-transition tests for loading, current, stale, offline, invalid, failed, and retry states in `test/features/prayer/azan_cubit_test.dart`
- [ ] T021 [P] [US2] Add controlled-clock tests for next-prayer boundaries, midnight/date rollover, timezone changes, and stale classification in `test/features/prayer/prayer_time_rules_test.dart`
- [ ] T022 [P] [US2] Add widget tests for visible home prayer loading, success, offline, stale, invalid, and failure states in `test/features/home/home_prayer_states_test.dart`

### Implementation for User Story 2

- [ ] T023 [US2] Replace nullable/silent prayer failures with typed observable outcomes in `lib/core/errors/failures.dart`, `lib/features/prayer/data/datasource/prayer_remote_data_source.dart`, and `lib/features/prayer/data/repositories/prayer_repository_impl.dart`
- [ ] T024 [US2] Define prayer freshness/provenance state data and controlled time seam in `lib/features/prayer/domain/entities/prayer_entity.dart` and `lib/features/prayer/presentation/cubit/azan_state.dart`
- [ ] T025 [US2] Implement validated prayer state transitions and retry behavior in `lib/features/prayer/presentation/cubit/azan_cubit.dart`
- [ ] T026 [US2] Render honest Arabic loading, current, stale, offline, invalid, and failure states without fixed fallback values in `lib/features/home/presentation/widgets/premium_prayer_card.dart`
- [ ] T027 [US2] Remove or clearly disable inactive/fixed home controls and resume placeholders in `lib/features/home/presentation/widgets/quran_resume_banner.dart` and `lib/features/home/presentation/widgets/home_body.dart`
- [ ] T028 [US2] Ensure prayer detail presentation displays validated location/date/freshness and recoverable failures in `lib/features/prayer/presentation/widgets/prayer_view_body.dart`

**Checkpoint**: User Story 2 is independently testable with no misleading prayer or home-state claims.

## Phase 5: User Story 3 — Review a Release Using Evidence (Priority: P2)

**Goal**: Give Ahmed a traceable production baseline, bounded backlog, release gate, and rollback record before implementation or rollout.

**Independent Test**: Review the baseline, finding register, traceability map, and release evidence record; every critical/high finding links to acceptance evidence, a task, an owner decision, and rollback relevance.

### Tests for User Story 3

- [ ] T029 [P] [US3] Add an artifact traceability check mapping FRs, risks, user stories, contracts, tests, and tasks in `test/specification/traceability_test.dart`
- [ ] T030 [P] [US3] Add a protected-file scope check that detects changes to staged/user-owned files and protected paths in `test/release/protected_scope_test.dart`

### Implementation for User Story 3

- [ ] T031 [US3] Complete the production baseline with package/release, permissions, dependency, route, asset, storage, test, and working-tree evidence in `specs/001-production-audit-protection/baseline.md`
- [ ] T032 [US3] Classify current findings, including silent prayer failures, hidden home errors, fixed demo values, inactive Quran resume behavior, unsafe route casts, and missing governance documents in `specs/001-production-audit-protection/audit-findings.md`
- [ ] T033 [US3] Map every functional requirement, risk, and acceptance scenario to evidence and ordered tasks in `specs/001-production-audit-protection/traceability.md`
- [ ] T034 [US3] Define staged-rollout approval, observation window, rollback trigger, and owner sign-off record in `specs/001-production-audit-protection/contracts/release-evidence.md`

**Checkpoint**: User Story 3 is independently reviewable without relying on undocumented implementation knowledge.

## Phase 6: User Story 4 — Use an Arabic-First Accessible Baseline (Priority: P2)

**Goal**: Verify and protect Arabic RTL readability, calm shared visual language, small-screen behavior, text scaling, and touch targets.

**Independent Test**: Run core journeys on a representative narrow Android viewport in Arabic RTL at default and 200% text scale; verify no essential clipping, blocked action, or undersized target.

### Tests for User Story 4

- [ ] T035 [P] [US4] Add widget tests for Arabic RTL and 200% text-scale layout across changed home, prayer, Quran, and Azkar surfaces in `test/accessibility/rtl_text_scale_test.dart`
- [ ] T036 [P] [US4] Add touch-target and narrow-screen assertions for changed interactive controls in `test/accessibility/touch_target_test.dart`
- [ ] T037 [P] [US4] Add startup and core-destination journey coverage in `test/integration/core_journeys_test.dart`

### Implementation for User Story 4

- [ ] T038 [US4] Audit and correct changed surfaces to use shared design tokens, Arabic strings, RTL ordering, and minimum touch targets in `lib/features/home/`, `lib/features/prayer/`, `lib/features/quran/`, and `lib/features/azkar/`
- [ ] T039 [US4] Define reusable Arabic loading, empty, error, offline, stale, and invalid states using existing shared widgets in `lib/core/widgets/` and affected feature widgets
- [ ] T040 [US4] Remove unsupported decorative or mixed visual treatments identified by the audit without altering verified religious source text in `lib/features/home/`, `lib/features/prayer/`, `lib/features/quran/`, and `lib/features/azkar/`

**Checkpoint**: User Story 4 is independently testable on small Arabic RTL screens at 200% text scale.

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Verify the complete protected release and preserve documentation traceability.

- [ ] T041 [P] Run `dart format --output=none lib test` and record the result in `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T042 [P] Run `flutter analyze` and record the result in `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T043 [P] Run relevant `flutter test` suites and record the result in `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T044 Run the complete `quickstart.md` validation matrix and attach outcomes to `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T045 Review the final diff for unrelated files, user-owned edits, persisted-key changes, route changes, asset changes, package identity changes, and unapproved religious-content changes in the repository root and `specs/001-production-audit-protection/contracts/release-evidence.md`
- [ ] T046 Confirm all critical/high findings have approved disposition, acceptance evidence, rollback relevance, and staged-release decision before implementation completion

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no implementation dependency and must preserve the current worktree.
- Foundational (Phase 2) depends on Setup and blocks all user-story implementation.
- US1 and US2 are both P1 and can proceed in parallel after Phase 2 if file ownership is separated; US2 touches prayer/home files while US1 focuses on compatibility/Quran/router tests.
- US3 depends on the evidence produced by Phase 2 and the findings from US1/US2.
- US4 depends on the state behavior selected for US1/US2 and can then proceed in parallel on presentation/accessibility files.
- Polish depends on all selected stories and owner review.

### User Story Dependencies

- **US1**: After Foundational; independent MVP.
- **US2**: After Foundational; independent P1 increment, with shared evidence from US1 only at release review.
- **US3**: After Foundational; evidence becomes complete after US1/US2 findings are known.
- **US4**: After Foundational; presentation validation should follow the state contracts from US1/US2.

### Parallel Opportunities

- T002–T004 can run in parallel.
- T006–T009 can run in parallel after T005 where files differ.
- T011–T014 can run in parallel.
- T019–T022 can run in parallel.
- T029–T030 and T035–T037 can run in parallel.
- US1 and US2 can be staffed in parallel after Phase 2 with explicit file ownership.
- T041–T043 can run in parallel after implementation changes stabilize.

## Parallel Example: MVP (User Story 1)

```text
Task T011: Quran persistence compatibility tests
Task T012: Route-contract tests
Task T013: Offline asset integrity tests
Task T014: Upgrade fixture tests
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational phases.
2. Implement US1 only: compatibility, upgrade safety, route recovery, and offline content integrity.
3. Stop and validate US1 independently before selecting any further story.

### Incremental Delivery

1. Add US2 prayer/home honesty after US1 evidence passes.
2. Add US3 release evidence and traceability.
3. Add US4 accessibility and visual baseline.
4. Run the full polish/release gate and stage rollout only after Ahmed's approval.

### Safety Rules

- Do not edit or restore staged-deleted governance files without owner approval.
- Do not modify Quran/Azkar source text or introduce generated religious content.
- Do not change persisted keys, route contracts, package identity, signing setup, or asset paths without an approved migration and rollback plan.
- Before implementation, Ahmed must explicitly select the task IDs and review affected files, assumptions, risks, and tests.
