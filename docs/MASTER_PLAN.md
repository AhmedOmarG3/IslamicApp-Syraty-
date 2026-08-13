# Siraty Master Product and Engineering Plan

## 1. Product vision

Siraty is a calm, trustworthy, Arabic-first daily Islamic companion. It should
help users pray on time, continue Quran reading, complete daily Azkar, and use
Tasbeeh with minimal distraction.

The product is not defined by how many features it contains. It is defined by
the reliability, clarity, religious-content integrity, and continuity of its
core daily journeys.

## 2. Product pillars

Every feature must support at least one pillar:

1. **Prayer awareness** — correct, transparent, user-configurable prayer information.
2. **Quran continuity** — make it easy to return, read comfortably, and preserve progress.
3. **Daily remembrance** — focused Azkar and Tasbeeh experiences with gentle progress.
4. **Offline trust** — essential content remains available or degrades honestly offline.
5. **Calm accessibility** — Arabic-first, readable, consistent, and usable by different ages.

## 3. Primary navigation

Use a simple four-destination bottom navigation after the foundation release:

- **Home** — next prayer and relevant daily actions.
- **Quran** — reading, resume, bookmarks, search, and later audio.
- **Azkar** — contextual sessions, categories, favorites, and progress.
- **More** — Tasbeeh, Qibla when ready, settings, downloads, sources, and about.

Prayer details are opened from the home prayer card and may also be available
inside More. Do not add a bottom-navigation destination for every feature.

## 4. Islamic visual direction

### Personality

- Peaceful, respectful, warm, clear, and content-led.
- Contemporary without following short-lived visual trends.
- Islamic identity through geometry, rhythm, typography, and restrained color—not
  through excessive mosque imagery or decorative ornaments.

### Design rules

- Use one dark green primary color, calm mint containers, a warm off-white
  background, charcoal text, and one restrained gold accent.
- Use gradients only on a meaningful hero surface such as the next-prayer card.
- Use subtle borders or light elevation, never heavy versions of both.
- Use one consistent vector/Material icon family.
- Do not use emoji or mixed clip-art as feature icons.
- Use Islamic geometric patterns only at very low contrast and only where they
  do not compete with text.
- Maintain one primary action per screen.
- Use consistent states: loading, empty, error, offline, stale, disabled, and success.
- Minimum touch target: 48×48 logical pixels.
- Changed flows must work on small Android devices and with text scaling to 200%.
- Animation should explain transition or progress and respect reduced-motion settings.

### Typography

- General Arabic UI: a highly readable Arabic UI family with defined weights.
- Quran text: a separately validated Quran/Uthmani font and verified source data.
- Never use decorative font styling for long interface labels.
- Provide user-controlled Quran font size and comfortable line spacing.
- Keep numerals, prayer times, and countdowns clear and directionally correct in RTL.

### Core design components

- `SiratyScaffold`
- `SiratyAppBar`
- `SiratyBottomNavigation`
- `SiratyPrimaryButton`
- `SiratySecondaryButton`
- `SiratyCard`
- `SiratyListTile`
- `SiratySectionHeader`
- `SiratySearchField`
- `SiratyLoadingState`
- `SiratyEmptyState`
- `SiratyErrorState`
- `SiratyOfflineBanner`
- `SiratyStaleDataBadge`
- `SiratyProgressIndicator`
- `SiratyPermissionRationale`

Component names are proposed, not mandatory. Reuse or rename existing components
when that avoids needless duplication.

## 5. Full release roadmap

Each release must pass its exit gate before the next major release begins.

---

## Release 0 — Production audit and protection

### Goal

Understand the exact live product and make future changes recoverable.

### Product work

- Record current Google Play listing, screenshots, version, reviews, installs,
  crash rate, ANRs, and device/Android distribution.
- Identify the most-used and least-used screens if analytics are legally and
  technically available.
- Create a short user feedback form for existing users.
- Confirm every religious data source and its license/attribution.

### Engineering work

- Tag or branch the exact production source.
- Document package ID, signing process, release steps, API provider, and persisted keys.
- Review current uncommitted changes before any feature work.
- Create upgrade and manual regression checklists.
- Replace stale README/package descriptions.
- Inspect security configuration and ensure signing/API secrets are not tracked.

### Exit gate

- Production source is recoverable.
- User data/storage keys are documented.
- Core journeys have a repeatable manual test.
- Existing edits are understood and safely separated.

---

## Release 1 — Code health, tests, and CI

### Goal

Create a safe baseline before redesigning user-facing behavior.

### Features and improvements

- Quran JSON parsing tests.
- Azkar JSON parsing tests.
- Prayer API fixture and parsing tests.
- Quran last-read storage and Cubit tests.
- Azkar loading/error Cubit tests.
- Router smoke tests for core destinations.
- CI for formatting, static analysis, and tests.

### Code improvements

- Resolve source encoding problems without altering verified religious content.
- Consolidate duplicate theme/constants files incrementally.
- Replace swallowed errors with typed failures in touched flows.
- Update architecture documentation to match actual dependencies and files.
- Remove hard-coded demo data from production surfaces when its real state is ready.

### Exit gate

- Format, analyze, and tests pass in CI.
- Core parsing and stored progress are protected.
- No source file containing verified religious content is changed without validation.

---

## Release 2 — Design system and application shell

### Goal

Create a consistent Islamic visual system before redesigning screens.

### UX work

- Audit all current colors, typography, spacing, radii, icons, images, and shadows.
- Create grayscale wireframes for Home, Quran list/reader, Azkar list/session,
  Prayer details, Tasbeeh, Settings, and More.
- Validate information hierarchy before applying color.
- Finalize light theme and accessible color contrast.
- Prepare dark-theme tokens, even if dark mode ships later.
- Define RTL behavior and accessibility semantics.

### Engineering work

- Implement semantic design tokens.
- Build/refine shared components and a test-only component gallery.
- Add golden/widget tests for key components where stable and useful.
- Establish bottom navigation and state-preserving navigation behavior.

### Exit gate

- No new screen uses arbitrary styling outside the system.
- Core components work in RTL, small screens, and 200% text scale.
- Navigation is understandable and does not expose dead destinations.

---

## Release 3 — Reliable Prayer Foundation

### Goal

Make prayer information trustworthy before adding notifications.

### User features

- City selection with saved recent/selected location.
- Optional device location only with clear permission rationale and manual fallback.
- Calculation-method selection.
- Asr method selection where relevant.
- 12/24-hour time setting.
- Manual minute adjustment per prayer when justified.
- Visible selected location, calculation method, and data freshness.
- Offline display of last valid cached timings with a stale label.
- Clear retry, invalid location, no connection, and unavailable states.

### Engineering work

- Typed network, timeout, invalid-response, invalid-location, cache, and stale failures.
- Validated API models and fixtures.
- Local cache with date, location, method, timezone, and retrieval time.
- Testable next-prayer calculation, including tomorrow's Fajr after Isha.
- Injectable clock and timezone/date-change tests.
- Separation of sunrise from obligatory prayers.

### Exit gate

- Prayer behavior is tested before Fajr, between prayers, after Isha, offline,
  after restart, and across date/timezone changes.
- The UI never silently displays stale or mismatched-location times.

---

## Release 4 — Reliable Daily Home

### Goal

Turn the home screen into a useful daily decision surface.

### Home content order

1. Current Hijri/Gregorian context and a neutral greeting.
2. Next-prayer hero with time, countdown, location, and freshness state.
3. Primary contextual action: Continue Quran or Start Reading.
4. Morning/evening Azkar action based on local time.
5. Compact shortcuts for Quran, all Azkar, Tasbeeh, and prayer details.
6. Optional verified daily content only if its source is clear and useful.

### Required behavior

- No hard-coded name, prayer, countdown, Quran position, or fake notifications.
- Actual Quran resume using the compatible stored key.
- Start Reading when no progress exists.
- Contextual Azkar never prevents access to other categories.
- Offline/stale prayer behavior remains visible.
- Qibla remains hidden until its complete release.
- Returning users bypass onboarding.

### Exit gate

- Widget tests cover loading, ready, no-progress, offline, stale, and failure states.
- Integration journey: launch → prayer state → Quran read → save → home resume.
- Home works at 200% text scale without clipped primary actions.

---

## Release 5 — Quran Reading Continuity

### Goal

Make Quran reading the strongest, most comfortable product experience.

### Feature 5.1: Verse-level resume

- Save Surah, verse, optional scroll anchor, and timestamp.
- Migrate from existing Surah-level key without losing progress.
- Show last-read information on Home and Quran landing screen.
- Restore gracefully if the underlying data structure changes.

### Feature 5.2: Bookmarks

- Bookmark/unbookmark a verse.
- List bookmarks grouped or sorted clearly.
- Navigate directly to the verse.
- Optional private note only after the base bookmark behavior is stable.
- Local-first storage and export readiness.

### Feature 5.3: Reading settings

- Quran font size.
- Line spacing or reading density.
- Light, dark, and warm reading surface.
- Optional keep-screen-awake control.
- Persist settings locally.

### Feature 5.4: Offline search

- Search Surah names and Quran text.
- Normalize Arabic forms carefully without modifying displayed source text.
- Highlight matched text and navigate to the exact verse.
- Test normalization and result correctness.

### Feature 5.5: Gentle reading goal

- Optional target by verses, pages, or time.
- Daily progress without competitive social behavior.
- No guilt-inducing language or aggressive streak-loss messaging.

### Exit gate

- Upgrade preserves old resume data.
- Search/bookmarks work offline.
- Quran text accuracy is verified after all storage/rendering changes.
- Reader performs smoothly on long Surahs and older devices.

---

## Release 6 — Guided Azkar Experience

### Goal

Transform static Azkar text into a focused, accessible session.

### Features

- Category search and favorites.
- One-Zekr-at-a-time guided session option.
- Required, completed, and remaining repetition counts.
- Large accessible tap target to increment.
- Optional haptic feedback.
- Automatic next item with a user-controlled setting.
- Session progress preserved after accidental navigation/process restart.
- Resume incomplete morning/evening session from Home.
- Completion summary without competitive gamification.
- Accurate text sharing first; consistent image sharing may follow.

### Religious integrity

- Built-in Azkar remains separate from user-created personal phrases.
- Sharing never truncates or paraphrases verified content silently.
- Source/reference information remains available where present.

### Exit gate

- Repetition behavior is testable and cannot skip/duplicate progress accidentally.
- Text remains readable with large scaling.
- Progress is preserved and can be reset intentionally.

---

## Release 7 — Tasbeeh Rebuild

### Goal

Replace the fragile image-overlay implementation with responsive, persistent controls.

### Features

- Responsive Flutter counter surface.
- Target: 33, 34, 100, or custom.
- Built-in phrase selection.
- Optional vibration/sound with settings.
- Persistent current counter and selected phrase.
- Reset confirmation when progress exists.
- Simple private history only if it provides user value.
- Personal phrase collection clearly labeled as user-created.

### Exit gate

- Works consistently across supported screen sizes.
- Counter survives navigation and restart.
- No accidental reset or double count under rapid taps.

---

## Release 8 — Prayer Notifications

### Goal

Provide reliable, user-controlled reminders using the established prayer foundation.

### Features

- Opt in separately for each prayer.
- Reminder before prayer with configurable lead time.
- User choice of silent, vibration, notification sound, or permitted Adhan audio.
- Clear Android notification/exact-alarm permission education.
- Reschedule after reboot, timezone change, location change, calculation change,
  daylight-saving change, and app update.
- Notification status/diagnostic screen.
- Battery-optimization guidance only when relevant.

### Exit gate

- Scheduled times match displayed prayer times.
- Reboot and timezone tests pass on supported Android versions.
- Denied permissions never break the prayer screen.
- Users can disable everything easily.

---

## Release 9 — Quran Audio

### Goal

Add reliable, licensed recitation without harming offline storage or app stability.

### Features

- Verified/licensed reciter and audio source.
- Surah or verse playback.
- Background playback and system media controls.
- Resume position.
- Download for offline listening.
- Wi-Fi-only option.
- Download progress, cancellation, retry, storage usage, and deletion.
- Clear unavailable/offline states.
- Optional playback speed if appropriate.

### Exit gate

- Source license and attribution are documented.
- Interrupted downloads recover safely.
- Background playback behaves correctly.
- The app clearly reports storage impact and lets users delete downloads.

---

## Release 10 — Qibla

### Goal

Ship a trustworthy compass, not a decorative rotating image.

### Features

- Location permission with manual explanation and denial fallback.
- Sensor availability check.
- Correct Qibla bearing calculation.
- Calibration instructions.
- Accuracy and magnetic-interference warning.
- Unsupported-device state.
- Optional map/static direction fallback if feasible and privacy-safe.

### Exit gate

- Bearing calculations have unit tests using known coordinates.
- Real-device testing covers calibration and interference.
- Unsupported sensors never produce a fake direction.

---

## Release 11 — Ramadan Mode

### Goal

Compose existing reliable prayer, Quran, and Azkar capabilities into a seasonal experience.

### Features

- Suhoor/Fajr and Maghrib/Iftar context from verified prayer data.
- Optional Quran completion plan.
- Ramadan reading progress.
- Verified Ramadan Duas/content with sources.
- User-controlled reminders.
- Seasonal home presentation that can be disabled.

### Exit gate

- No duplicate prayer/Quran logic.
- Date boundaries and regional differences are handled transparently.
- Seasonal mode turns on/off safely without losing normal preferences.

---

## Release 12 — Backup, Restore, and Privacy

### Goal

Protect reading progress, bookmarks, preferences, Azkar progress, and Tasbeeh state.

### Stage 1: Local export/import

- Versioned export format.
- Preview before restore.
- Validation and corruption handling.
- Merge versus replace decision made explicit.
- Sensitive notes protected appropriately.

### Stage 2: Optional cloud sync

Only after local backup is stable and long-term maintenance is possible:

- Authentication and account deletion.
- Encryption/privacy design.
- Conflict resolution.
- Offline queue and retry.
- Privacy policy and data export/deletion obligations.

### Exit gate

- Restore is tested across app versions.
- Corrupt/partial backups cannot destroy existing data.
- Cloud sync does not ship without a support and security plan.

## 6. Settings information architecture

Settings should eventually contain:

- Appearance: theme, text scaling guidance, reading surface.
- Quran: font size, line spacing, keep screen awake, audio/download preferences.
- Prayer: location, calculation method, Asr method, manual adjustments, time format.
- Notifications: per-prayer and Azkar reminder controls.
- Storage: downloaded audio, backup/export/import.
- Accessibility: haptic feedback, reduced motion where supported.
- Privacy: analytics/crash reporting disclosure and controls where applicable.
- About: app version, religious content sources, licenses, privacy policy, feedback.

## 7. Cross-cutting engineering roadmap

Apply these gradually when required by active features:

- Typed result/failure model.
- Network timeouts, validation, retry rules, and safe logs.
- Versioned local persistence and migration tests.
- Injectable clock, location, notification scheduler, and sensor boundaries.
- Localization-ready strings instead of scattered literals.
- Feature flags for risky staged releases where useful.
- Crash/ANR monitoring with privacy review.
- Performance profiling for startup, JSON parsing, long lists, and audio.
- Accessibility semantics and keyboard/focus behavior where applicable.
- CI and release checklist.

Do not create every abstraction in advance. Add it when the selected feature
needs it and tests demonstrate its value.

## 8. Feature prioritization score

Before moving a feature into active development, score 1–5:

| Criterion | Question |
|---|---|
| Repeated user value | Will users return to this regularly? |
| Product fit | Does it support Siraty's five product pillars? |
| Religious/user trust | Can it be correct and transparent? |
| Offline resilience | Can it work or degrade honestly offline? |
| Maintainability | Can Ahmed support it during military service? |
| Portfolio value | Does it demonstrate meaningful engineering? |
| Evidence | Do reviews, analytics, or user interviews support it? |
| Risk | What is the damage if it behaves incorrectly? |

High-risk features require stronger evidence, tests, and rollout controls.

## 9. Spec Kit workflow for every release

Use this sequence for one release or coherent feature only:

```text
$speckit-specify <feature outcome, users, behavior, constraints, acceptance criteria>
$speckit-clarify
$speckit-plan
$speckit-tasks
$speckit-checklist
$speckit-analyze
```

Then select a small task group and run:

```text
$speckit-implement
```

Required instruction before implementation:

```text
Implement only tasks [IDs]. Before editing, list affected files, assumptions,
user-data/religious-content/release risks, and tests. Preserve existing keys,
routes, assets, and user changes. Do not edit unrelated files. After editing,
run the relevant quality gates and explain the evidence.
```

## 10. Recommended immediate start

Do not start audio, notifications, Qibla, Ramadan, or cloud sync now.

Start in this order:

1. Release 0 production protection.
2. Release 1 baseline tests and CI.
3. Release 3 prayer domain foundation.
4. Release 2 design components needed by the home screen.
5. Release 4 Reliable Daily Home.
6. Release 5 Quran Reading Continuity.
7. Release 6 Guided Azkar.
8. Release 7 Tasbeeh rebuild.

The design system and prayer work may overlap only through small reviewed task
groups. If the six-week period ends, stop at the last stable staged release.

## 11. Full-app definition of success

Siraty is successful when:

- existing users upgrade without losing progress;
- prayer information is correct and transparent;
- Quran/Azkar essential content works offline;
- home actions connect to real state rather than demo data;
- Quran and Azkar sessions preserve continuity;
- the UI is coherent, Arabic-first, accessible, and free of dead controls;
- every sensitive feature has permission, failure, and rollback behavior;
- religious content is verified and never generated;
- automated tests protect critical rules and user journeys;
- releases are staged, observable, and maintainable by Ahmed.
