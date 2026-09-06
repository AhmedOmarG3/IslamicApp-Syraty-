# Feature Specification: Production Audit and Protection

**Feature Branch**: `not-created`

**Created**: 2026-08-13

**Status**: Draft

**Input**: User description: "Improve the existing Siraty app based on the master plan. Begin with production audit and protection. Inspect the current code and define the feature requirements, user scenarios, acceptance criteria, risks, data compatibility rules, Islamic-content rules, UI/UX requirements, and tests. Do not implement code yet."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Upgrade Without Losing Trust or Progress (Priority: P1)

As an existing Siraty user, I can install a protected release and continue using my existing routes, Quran progress, offline religious content, and familiar core journeys without data loss or an unexplained behavior change.

**Why this priority**: Siraty is already in production. Preventing regressions for current users is more important than adding new capability.

**Independent Test**: Install the protected release over a representative existing installation containing saved Quran progress, then verify that the app opens, preserved routes work, stored progress is retained, and Quran and Azkar content remains available offline.

**Acceptance Scenarios**:

1. **Given** an existing installation with a saved Quran position, **When** the user upgrades and opens Quran, **Then** the stored position remains readable and unchanged unless the user intentionally updates it.
2. **Given** a user or saved navigation action targets an existing route, **When** the protected release handles it with valid arguments, **Then** it reaches the same user journey without requiring a migration.
3. **Given** the device is offline, **When** the user opens Quran or Azkar, **Then** the verified bundled content remains usable and is not replaced, regenerated, or presented as network-dependent.
4. **Given** an upgrade candidate changes a persisted key, route contract, package identity, signing configuration, or asset path, **When** it is reviewed, **Then** release approval is blocked until a migration, validation, rollback, and staged-release plan is approved.

---

### User Story 2 - Receive Honest Daily Information (Priority: P1)

As a daily user, I see real, current, and clearly qualified information on home and prayer surfaces, including visible loading, offline, stale, invalid-data, and failure states instead of hidden errors, fixed demo values, or unsupported claims.

**Why this priority**: Prayer information and daily actions are trust-sensitive. Incorrect or fabricated freshness can mislead users.

**Independent Test**: Exercise successful, slow, malformed, offline, stale, and failed prayer-data cases and confirm that every state is distinguishable, actionable, and never represented by invented prayer names, times, countdowns, or location freshness.

**Acceptance Scenarios**:

1. **Given** valid prayer data for a known location and date, **When** home is displayed, **Then** the user sees prayer information tied to that location and date with no fixed fallback masquerading as calculated data.
2. **Given** prayer data cannot be retrieved or validated, **When** home is displayed, **Then** the prayer surface remains visible with a clear Arabic error or offline state and a recovery action where recovery is possible.
3. **Given** previously obtained prayer data is shown after it is no longer fresh, **When** the user views it, **Then** it is explicitly labeled with its location/date and stale status.
4. **Given** a home control has no working end-to-end journey, **When** the release is audited, **Then** the control is hidden, disabled with an honest explanation, or excluded from release; it is not shipped as an active dead control.

---

### User Story 3 - Review a Release Using Evidence (Priority: P2)

As Ahmed, I can review a documented production baseline and a bounded protection backlog before any feature implementation, with traceability from each high-risk finding to an acceptance criterion, test, owner decision, and release gate.

**Why this priority**: A durable audit prevents broad refactoring and allows safe, small task selection.

**Independent Test**: Review the audit inventory and confirm that every production-critical surface has a recorded current behavior, risk level, compatibility constraint, required evidence, and disposition.

**Acceptance Scenarios**:

1. **Given** the current application and working tree, **When** the audit is completed, **Then** it inventories routes, persisted values, bundled religious assets, network-dependent flows, permissions, package/release identity, dependencies, dead controls, error handling, accessibility, and existing tests.
2. **Given** pre-existing uncommitted or staged edits, **When** audit artifacts are produced, **Then** those edits are identified and preserved without being overwritten, reverted, or silently absorbed into the feature scope.
3. **Given** an audit finding, **When** it is accepted into the protection backlog, **Then** it has severity, affected users, acceptance evidence, regression risk, and rollback relevance.
4. **Given** a proposed implementation task group, **When** Ahmed reviews it, **Then** implementation does not begin until he explicitly selects and approves that small group.

---

### User Story 4 - Use an Arabic-First Accessible Baseline (Priority: P2)

As a user on a small Android screen or using enlarged text, I can understand and operate audited core surfaces in Arabic and RTL without clipped religious text, obscured actions, undersized targets, or inconsistent visual language.

**Why this priority**: Accessibility and Arabic-first presentation are product requirements and common regression points during stabilization.

**Independent Test**: Review core journeys on a representative small Android viewport in RTL at default and 200% text scale, checking navigation, content readability, state messages, and touch targets.

**Acceptance Scenarios**:

1. **Given** Arabic RTL layout at 200% text scale, **When** the user views an audited core surface, **Then** essential content and actions remain readable, reachable, and correctly ordered.
2. **Given** an interactive audited control, **When** its touch area is measured, **Then** it is at least 48 by 48 logical pixels.
3. **Given** loading, empty, error, offline, or stale states relevant to a surface, **When** that state occurs, **Then** the message is clear in Arabic, does not expose technical details, and preserves the calm shared visual hierarchy.

### Edge Cases

- An existing saved Quran index is absent, at a boundary, or outside the current content range.
- A route is opened directly with missing, malformed, or incompatible arguments.
- Bundled Quran or Azkar assets are missing, unreadable, structurally invalid, or unintentionally changed.
- Prayer data succeeds but contains missing fields, invalid times, a mismatched location/date, or an unexpected response shape.
- Connectivity changes during loading, or only stale prayer information is available.
- Device time, timezone, locale, or date changes while a prayer-related surface is visible.
- A user upgrades from the oldest production version for which compatible data can be obtained.
- Text scaling, narrow width, long Arabic labels, or system navigation causes overflow or inaccessible actions.
- A current control appears actionable but has no complete destination or real state behind it.
- The audit encounters staged or uncommitted changes whose ownership or intended release is not yet documented.

## Requirements *(mandatory)*

### Functional Requirements

#### Production Audit and Release Protection

- **FR-001**: The feature MUST produce a production baseline inventory covering current core journeys, routes and route arguments, persisted values, bundled assets, network dependencies, permissions, package and release identity, supported platforms, third-party dependencies, tests, and current working-tree changes.
- **FR-002**: Each audit finding MUST record severity, observable current behavior, affected journey or data, user/religious/release impact, required acceptance evidence, and recommended disposition.
- **FR-003**: Findings that can cause data loss, religious-content corruption, incorrect prayer representation, startup failure, inaccessible core journeys, or incompatible upgrades MUST block release until resolved or explicitly accepted by Ahmed with a documented mitigation and rollback decision.
- **FR-004**: Production-protection work MUST be divided into small independently reviewable task groups; no group may silently expand into a whole-application rewrite.
- **FR-005**: Existing staged and uncommitted changes MUST be treated as user-owned, identified in the audit, and excluded from modification unless they are explicitly selected for a later task.
- **FR-006**: The audit MUST identify dead controls, fixed/demo content presented as real, silent failures, unsafe input assumptions, and unsupported product claims across core journeys.
- **FR-007**: Before a production-changing task is approved, its release evidence MUST define upgrade coverage, regression coverage, rollback trigger, staged-rollout observation, and user-visible failure behavior.

#### Data and Compatibility Protection

- **FR-008**: The existing package identity, signing expectations, route paths, route argument contracts, asset paths, and persisted storage keys MUST remain compatible by default.
- **FR-009**: The existing Quran last-read key `last_read_index` and its readable existing values MUST be preserved; any proposed replacement requires an approved migration that is idempotent, validates results, retains rollback capability, and does not erase the old value prematurely.
- **FR-010**: Existing saved values that are absent or invalid MUST degrade safely without crashing or silently overwriting user data; the user MUST be able to recover through a valid default journey.
- **FR-011**: Existing routes `/`, `/home`, `/quran`, `/surah-details`, `/azkar`, `/zekr-details`, `/tasbeeh`, and `/prayer` MUST remain reachable with their valid current contracts unless an approved compatibility plan provides redirects or adapters.
- **FR-012**: Missing or malformed route arguments MUST produce a safe recoverable outcome rather than an unhandled failure.
- **FR-013**: Existing bundled asset paths, including Quran and Azkar source assets, MUST not change without an approved compatibility and rollback plan.
- **FR-014**: Tasbeeh's current session-only state MUST not be represented as persisted progress; any future persistence behavior is outside this protection scope unless separately specified and approved.

#### Islamic-Content Integrity

- **FR-015**: Quran, Azkar, translations, Hadith, prayer guidance, and devotional phrases MUST NOT be generated, completed, paraphrased, translated, or silently corrected by generative AI.
- **FR-016**: The audit MUST fingerprint or otherwise establish a comparison baseline for bundled Quran and Azkar source files so unintended content changes can be detected before release.
- **FR-017**: Any intentional religious-content change MUST identify its verified source, attribution, reviewer, exact comparison evidence, automated integrity checks, and Ahmed's explicit approval.
- **FR-018**: Quran Arabic characters, ordering, verse relationships, and Azkar text MUST remain byte-for-byte or canonically equivalent to the approved source according to a documented validation rule; visual refactoring MUST NOT alter the source text.
- **FR-019**: Prayer information MUST be presented as calculated or retrieved information for an identified place and date, not as a religious ruling, and MUST never use invented fallback times or countdowns.

#### Honest States and UI/UX Baseline

- **FR-020**: Every audited stateful core surface MUST define relevant loading, content, empty, error, offline, stale, and invalid-data behavior.
- **FR-021**: Network and data failures MUST remain distinguishable for diagnosis and user recovery; failures MUST NOT be silently converted into an absent value or hidden surface.
- **FR-022**: Cached or stale prayer information, if shown, MUST display its associated location/date and stale status and MUST not be represented as fresh.
- **FR-023**: Active controls MUST complete a real supported journey. Controls without end-to-end behavior MUST be hidden or clearly unavailable before release.
- **FR-024**: Changed or audited core surfaces MUST be Arabic-first and RTL-correct, remain usable on small Android screens and at 200% text scale, and provide touch targets of at least 48 by 48 logical pixels.
- **FR-025**: UI assessment MUST use the established shared visual language and MUST flag arbitrary colors, spacing, radii, shadows, typography, gradients, emoji navigation, fake personalization, and inconsistent icon styles.
- **FR-026**: Error and recovery messages MUST be understandable Arabic, preserve user context where safe, and avoid unsupported assurances or raw technical details.

#### Verification Requirements

- **FR-027**: A compatibility test suite MUST cover clean install, upgrade with existing saved Quran progress, missing/invalid persisted values, and existing route contracts.
- **FR-028**: Automated integrity tests MUST verify that approved Quran and Azkar assets are present, parseable, structurally valid, and unchanged from the approved audit baseline unless a content change is separately approved.
- **FR-029**: Prayer tests MUST cover success, timeout, offline, malformed data, non-success response, stale data, location/date labeling, next-prayer boundary transitions, midnight/date rollover, timezone changes, and recovery.
- **FR-030**: Any time-dependent prayer rule introduced after this specification MUST be verifiable against a controlled time source.
- **FR-031**: State-management tests MUST verify meaningful loading, success, failure, retry, offline, stale, and invalid-data transitions for changed core flows.
- **FR-032**: Widget or journey tests MUST cover startup, navigation to each current core destination, Quran resume behavior, prayer-state visibility, offline Quran/Azkar access, Arabic RTL layout, 200% text scaling, small-screen layout, and minimum touch targets for changed surfaces.
- **FR-033**: Release approval MUST require formatting, static analysis, all relevant automated tests, documented manual accessibility/RTL checks, and a review showing no unrelated files or user-owned edits were changed.
- **FR-034**: The audit MUST establish a baseline for startup stability and core-journey completion using representative production-like data, with zero critical crashes or data-loss events in the tested release candidate.

### Scope Boundaries

This feature specifies the audit and protection foundation only. It does not implement the Reliable Daily Home redesign, prayer calculation redesign, notifications, Qibla, audio, Ramadan features, cloud sync, analytics, crash-reporting services, new religious content, new persistence for Tasbeeh, or broad architecture refactoring. Findings may create later task candidates, but implementation requires a separately selected small task group.

### Risk Register

- **R-001 — Existing-user data loss (Critical)**: Stored Quran progress could be lost or misread. Mitigation requires key/value inventory, upgrade fixtures, validation, and rollback preservation.
- **R-002 — Religious-content alteration (Critical)**: Encoding, parsing, asset, or editorial changes could corrupt verified text. Mitigation requires approved-source baselines and exact integrity checks.
- **R-003 — Misleading prayer information (Critical)**: Fixed, stale, location-mismatched, or invalid data could be shown as current. Mitigation requires explicit provenance/freshness states and boundary tests.
- **R-004 — Startup/navigation regression (High)**: Invalid route arguments or initialization changes could block core journeys. Mitigation requires route-contract and startup tests.
- **R-005 — Hidden production failures (High)**: Silent error conversion or disappearing UI can conceal outages. Mitigation requires observable failure categories and visible recovery states.
- **R-006 — Accidental scope absorption (High)**: Existing staged/uncommitted edits could be overwritten or incorrectly attributed. Mitigation requires diff review and file-level scope approval.
- **R-007 — Accessibility regression (Medium)**: Arabic text, scaling, small screens, or touch targets may fail. Mitigation requires repeatable RTL/accessibility checks.
- **R-008 — Release-process gap (High)**: A technically passing build could still be unsafe to roll out. Mitigation requires upgrade evidence, staged rollout, rollback triggers, and owner approval.
- **R-009 — Missing governance context (Medium)**: Required product/roadmap/progress documents are currently absent from the working tree. Mitigation requires restoring or explicitly superseding their durable guidance before later planning claims full roadmap traceability.

### Key Entities *(include if feature involves data)*

- **Production Baseline**: The reviewed snapshot of app identity, routes, stored values, content assets, journeys, dependencies, working-tree state, and verification evidence.
- **Audit Finding**: A documented discrepancy or risk with severity, affected users/data/content, evidence, disposition, and release-blocking status.
- **Compatibility Contract**: A user-observable or stored interface that upgrades must preserve, such as a key, route, argument shape, package identity, or asset path.
- **Religious Content Baseline**: The approved source identity and integrity evidence for Quran, Azkar, and other religious material.
- **Release Evidence Record**: The collection of automated results, manual checks, upgrade outcomes, known risks, rollout decision, and rollback trigger for a candidate release.
- **Data Freshness Descriptor**: The location, date, retrieval status, and freshness qualification attached to prayer information.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of identified persisted keys, current routes, route argument contracts, bundled religious assets, and package/release identifiers are recorded in the production baseline before implementation begins.
- **SC-002**: Representative upgrades preserve 100% of valid existing Quran progress samples, with zero destructive overwrites of missing or invalid values.
- **SC-003**: All current core destinations complete their valid navigation journey without a critical crash in the release candidate, and malformed route-input tests end in a recoverable state.
- **SC-004**: 100% of audited prayer states—loading, current, offline, stale, invalid, and failed—are visibly distinguishable and contain no invented prayer time, name, countdown, location, or freshness claim.
- **SC-005**: Approved Quran and Azkar baseline checks detect every intentional test mutation and produce zero unexplained content differences in the release candidate.
- **SC-006**: Quran and Azkar core content remains usable in 100% of planned offline journey tests.
- **SC-007**: 100% of active controls on changed production-protection surfaces lead to a complete supported action; zero known dead controls or fixed demo values are shipped as real behavior.
- **SC-008**: All changed core surfaces pass the defined small-screen, Arabic RTL, 200% text-scale, and 48-by-48 touch-target checks with no blocked primary action or clipped essential content.
- **SC-009**: The protected release candidate has zero critical crashes, zero observed data-loss events, and zero unapproved religious-content changes across the agreed production-like verification set.
- **SC-010**: Every critical or high audit finding has an approved disposition, acceptance evidence, and rollback relevance before staged rollout begins.
- **SC-011**: A reviewer can trace every proposed protection task to at least one audit finding, acceptance scenario, and verification requirement without relying on undocumented implementation knowledge.

## Assumptions

- This specification covers the first master-plan stage: production audit and protection, not the complete application-improvement roadmap.
- Existing production behavior is preserved unless it is unsafe, misleading, broken, or explicitly superseded through an approved compatibility plan.
- The current known persisted Quran progress key is `last_read_index`; the audit may discover additional persisted or platform-managed data that must be added to the baseline.
- Quran and Azkar remain bundled offline features; prayer information remains network-dependent during this stage.
- No new dependency, permission, analytics service, crash-reporting service, location behavior, or religious source is authorized by this specification.
- Ahmed is the approving owner for scope selection, religious-content changes, accepted production risk, and release rollout.
- The current staged deletions and existing edits are user-owned workspace changes and are not part of this specification-writing action.

## Dependencies

- Access to a representative current production build or release metadata and, where available, upgrade samples from supported previous versions.
- An approved reference for current Quran and Azkar bundled content.
- A documented set of supported Android versions/devices and the intended release channel for staged verification.
- Restoration or explicit replacement of the missing durable product, roadmap, autopilot, and progress documents before later phases claim complete cross-document alignment.
