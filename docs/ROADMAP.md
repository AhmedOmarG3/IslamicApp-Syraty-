# Siraty Active Roadmap

For the complete long-term product, feature, UI/UX, engineering, and release
strategy, read `docs/MASTER_PLAN.md`. This file remains the shorter active
execution roadmap.

## Now: Release 1 — Foundation and Reliable Daily Home

Goal: replace hard-coded daily information with correct, tested, failure-aware
behavior and establish a coherent design foundation.

### Milestone 0: Protect production

- Record Play Store version, package ID, signing/release process, crash/ANR data,
  and current reviews.
- Review and preserve the existing uncommitted home/splash changes.
- Inventory persisted keys and create an upgrade regression checklist.
- Replace placeholder README and package description.

### Milestone 1: Test baseline and CI

- Test Quran and Azkar JSON parsing.
- Test Quran last-read persistence and Cubit states.
- Test prayer response parsing with fixtures.
- Run format, analyze, and tests in GitHub Actions.

### Milestone 2: Design system

- Consolidate semantic colors, spacing, radius, typography, and component states.
- Separate Quran reading typography from general UI typography.
- Build/test app bar, card, button, input, loading, empty, error, offline, and
  stale-state components.
- Review in grayscale, Arabic RTL, small screen, and 200% text scale.

### Milestone 3: Reliable prayer domain

- Preserve typed network, timeout, validation, cache, and stale failures.
- Cache the last successful timings with city, date, and metadata.
- Calculate the real next prayer, including tomorrow's Fajr after Isha.
- Inject the clock and test boundaries/time changes.

### Milestone 4: Daily home

- Remove hard-coded name, prayer, countdown, inspiration, and resume values.
- Show next prayer, location, remaining time, and offline/stale states.
- Connect Start/Continue Quran to existing stored progress.
- Add contextual morning/evening Azkar shortcut.
- Keep only working shortcuts; hide Qibla until implemented.
- Add widget and critical-flow integration tests.

## Next: Release 2 — Reading and Dhikr Continuity

- Verse-level Quran resume with backward-compatible migration.
- Quran bookmarks.
- Adjustable Quran font size and improved verse separation.
- Azkar repetition/progress interaction and persisted completion where useful.
- Responsive Tasbeeh rebuilt without image-coordinate controls; persist counter.
- First-launch-only onboarding and basic settings.

## Later: Release 3 — User-Controlled Retention

Choose one main capability after user feedback and reliability evidence:

- Prayer notifications with explicit opt-in and calculation settings.
- Downloadable Quran audio with storage/network controls.
- Qibla with permission, sensor calibration, accuracy, and unsupported-device UX.
- Privacy-conscious backup/sync.

Do not build all of these in one release.

## Not now

- AI religious chatbot or generated Islamic content.
- Social feed, accounts, cloud sync, or gamification without validated demand.
- Full codebase rewrite.
- Multiple new state-management libraries.
- UI-only features with no real data or working action.

## Active Spec Kit feature

Start with:

```text
$speckit-specify Build Reliable Daily Home for Siraty using docs/PRODUCT.md and
docs/ROADMAP.md. Replace hard-coded home information with real next-prayer,
location/freshness, Quran resume, and contextual Azkar states. Preserve existing
storage keys and users. Hide unavailable Qibla. Include Arabic RTL, offline,
error, stale, accessibility, and upgrade acceptance criteria. Do not choose
implementation packages in the specification.
```

Then run:

```text
$speckit-clarify
$speckit-plan
$speckit-tasks
$speckit-analyze
```

Do not run `$speckit-implement` for the complete feature. Select the first small
task group—normally baseline tests and typed prayer behavior—review its affected
files, then implement and verify it.
