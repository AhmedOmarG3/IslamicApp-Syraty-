# Siraty Constitution

## Core Principles

### I. Protect Existing Users

Siraty is a production application. Existing routes, package identity, stored
preferences, Quran progress, assets, and user-visible behavior MUST remain
compatible unless an approved specification contains a migration, validation,
rollback, and staged-release plan. No feature may trade user data safety for a
faster implementation.

### II. Religious Content Is Verified, Never Generated

Quran, Azkar, translations, Hadith, prayer guidance, and other religious content
MUST come from identified, reviewed sources. Generative AI MUST NOT create,
complete, paraphrase, translate, or silently correct religious source content.
Content changes require explicit source attribution, comparison checks, tests,
and owner approval.

### III. Arabic-First, Calm, Accessible Design

Arabic, RTL layout, readable religious text, small Android devices, and text
scaling up to 200% are first-class requirements. UI MUST use semantic design
tokens and shared components. Every screen needs clear hierarchy and one obvious
primary action. Decorative gradients, excessive shadows, emoji/clip-art
navigation, fake personalization, dead controls, and inconsistent component
styles are prohibited.

### IV. Offline Reliability and Observable Failures

Quran and Azkar core content MUST remain usable offline. Network-dependent
features MUST define timeout, validation, offline, cached, stale, and complete
failure behavior. Errors MUST be typed and observable; implementations MUST NOT
catch failures and silently return `null`. Cached information MUST display its
location/date and MUST NOT be misrepresented as fresh.

### V. Tested, Incremental Engineering

Development MUST be incremental and limited to the approved task scope. Business
rules require unit tests, Cubits require state-transition tests, reusable UI
states require widget tests, and critical journeys require integration tests.
Time-dependent logic MUST be testable through an injected clock or equivalent.
`dart format`, `flutter analyze`, and relevant `flutter test` commands are
mandatory quality gates.

### VI. Simplicity Over Architecture Theater

Use feature-first organization, dependency injection, repositories, use cases,
and Cubits where they create real separation and testability. Do not add layers,
packages, patterns, or files only to claim Clean Architecture. Reuse existing
components, keep responsibilities focused, and justify every new dependency.

### VII. AI Accelerates; The Developer Owns

AI may assist with clarification, design alternatives, implementation, tests,
review, and documentation. Ahmed remains responsible for requirements,
religious-content integrity, architecture, privacy, verification, and release.
AI-generated work MUST be read, explained, tested, and implemented in small
reviewable task groups. Code that cannot be explained or maintained is not done.

## Product and Technology Constraints

- Product: Arabic-first daily Islamic companion for Quran, Azkar, prayer, and
  Tasbeeh use.
- Current stack: Flutter/Dart, Cubit, GetIt, GoRouter, Dio, SharedPreferences,
  ScreenUtil, local JSON assets.
- Existing last-read SharedPreferences keys remain compatible until a migration
  is explicitly approved.
- New packages require documented need, maintenance evaluation, license check,
  and owner approval.
- Privacy-sensitive analytics, crash reporting, location, and notifications
  require transparent user behavior and Play policy/privacy review.
- A feature not working end-to-end MUST be hidden or clearly labeled unavailable;
  it cannot ship as an inactive control.

## Development and Release Workflow

1. Inspect the current code, Git diff, persisted data, and production behavior.
2. Create a feature specification focused on user outcomes and acceptance criteria.
3. Clarify ambiguity, particularly religious data, location, time, offline, and
   migration behavior.
4. Create a technical plan with risks, tests, migration, and rollback.
5. Generate ordered tasks and analyze artifact consistency.
6. Implement a small selected task group; do not implement the complete backlog
   in one AI pass.
7. Verify automated tests plus Arabic/RTL, accessibility, offline, and upgrade
   behavior.
8. Use internal testing and staged rollout for material production changes.

## Governance

This constitution supersedes conflicting older AI, architecture, standards, and
refactoring guidance. An approved feature specification may add stricter rules
but cannot silently weaken these principles. Amendments require Ahmed's explicit
approval, a documented reason, affected artifacts, and a version update.

**Version**: 1.0.0 | **Ratified**: 2026-08-13 | **Last Amended**: 2026-08-13
