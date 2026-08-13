# Siraty AI Working Agreement

This is the authoritative entry point for any AI agent working in this repository.

## Read before acting

Read these files in order:

1. `docs/PRODUCT.md` — what Siraty is and who it serves.
2. `docs/MASTER_PLAN.md` — complete feature, design, engineering, and release plan.
3. `docs/ROADMAP.md` — shorter active execution roadmap.
4. `docs/AUTOPILOT.md` — guided automatic Spec Kit and commit workflow.
5. `docs/PROGRESS.md` — durable current release/stage/task pointer.
6. `.specify/memory/constitution.md` — non-negotiable project principles.
7. The active feature files under `specs/`, when they exist.
8. Relevant source files and tests for the selected task.

`AI_RULES.md`, `ARCHITECTURE.md`, `PROJECT_STANDARDS.md`, and
`REFACTORING_GUIDE.md` are historical supporting documents. If they conflict
with this file, the constitution, an approved feature specification, or the
actual codebase, follow the newer authoritative source.

## Current product status

- Siraty is a live Arabic-first Flutter application with 100+ Google Play users.
- Existing user data, routes, asset paths, and storage keys must remain compatible.
- Quran and Azkar are local/offline features. Prayer data currently comes from a
  remote API. Tasbeeh currently uses local widget state.
- The current priority is `Reliable Daily Home`, not adding many unrelated features.
- There are pre-existing uncommitted edits in `home_page.dart` and
  `splash_page.dart`. Do not overwrite, revert, or absorb them without reviewing
  their diff and confirming they belong to the active task.

## Mandatory workflow

For a meaningful feature, use Spec Kit in this order:

1. `$speckit-specify <feature description>`
2. `$speckit-clarify`
3. `$speckit-plan`
4. `$speckit-tasks`
5. `$speckit-analyze`
6. Implement only an explicitly selected small task group with
   `$speckit-implement` or normal coding work.

The constitution is already established. Use `$speckit-constitution` only when
Ahmed explicitly wants to amend project-wide principles.

When Ahmed asks to start, continue, resume, or automatically execute the roadmap,
use `$siraty-autopilot` for stage selection, one-task execution, verification,
learning logs, and one local commit per task.

Before editing code, always state:

- selected task IDs;
- assumptions and user-visible acceptance criteria;
- files expected to change;
- storage, release, religious-content, and regression risks;
- tests that will prove completion.

## Scope and safety

- Never rewrite the application wholesale.
- Never change unrelated files.
- Never discard user edits or use destructive Git commands.
- Do not change a persisted key, route argument, package ID, signing setup, or
  asset path without an approved migration and rollback plan.
- Do not add a dependency before explaining why the SDK/current dependencies
  cannot solve the problem.
- Do not expose signing files, API credentials, user data, or Play Console data.
- Do not fabricate supported functionality in UI, documentation, CV claims, or
  Play Store text.

## Islamic-content integrity

- Never generate or silently alter Quran text, Azkar text, translations,
  Hadith, prayer rulings, or religious claims with generative AI.
- Preserve verified source text exactly, including Arabic characters and verse
  relationships.
- Any content-source change requires source attribution, validation, tests, and
  explicit Ahmed approval.

## UI rules

- Arabic and RTL are first-class requirements.
- Use the shared design tokens and components. Do not introduce arbitrary colors,
  spacing, radii, shadows, typography, or mixed icon styles.
- Prefer calm content hierarchy over decorative cards and gradients.
- No glassmorphism, random gradients, excessive shadows, emoji navigation icons,
  or fake data.
- Minimum touch target is 48x48 logical pixels.
- Support small Android screens and text scaling up to 200% for changed flows.
- Every stateful surface must define loading, empty, error, offline, and stale
  behavior when those states are relevant.

## Engineering rules

- Keep business and time-calculation logic outside widgets.
- Use typed domain failures; do not catch errors and silently return `null`.
- Time-dependent logic must accept an injectable clock or equivalent test seam.
- Reuse existing code before creating abstractions.
- Prefer simple feature-first code. Clean Architecture layers must provide a real
  testing or maintenance benefit, not ceremonial files.
- New business rules require unit tests; Cubit transitions require Cubit tests;
  critical user journeys require widget or integration tests.
- Completion requires `dart format`, `flutter analyze`, and relevant
  `flutter test` commands to pass.

## Definition of done

A task is complete only when:

- its acceptance criteria are satisfied;
- important success and failure paths are tested;
- existing stored data and behaviors remain compatible;
- Arabic/RTL and accessibility were checked for UI changes;
- documentation/spec artifacts reflect the implemented behavior;
- no dead control, hard-coded demo state, secret, or unsupported claim remains;
- the agent can explain the design decisions and verification evidence clearly.

<!-- SPECKIT START -->
For generated feature context, also read the current plan produced by Spec Kit.
<!-- SPECKIT END -->
