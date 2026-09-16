# Implementation Plan: Prayer Times, Adhan, Notifications & Android Widget

**Branch**: `002-prayer-times-adhan-widget` | **Date**: 2026-09-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-prayer-times-adhan-widget/spec.md`

## Summary

Replace the current remote-API prayer pipeline with a fully offline,
worldwide prayer-time domain: local astronomical calculation
(`adhan_dart`), per-country method auto-selection with user override,
location via one-tap device detection or offline city search, derived
prayer status / next-prayer / countdown, a persisted single-source prayer
snapshot, Android exact-alarm scheduling of 10-minute reminders and
on-time Adhan (survives kill/Doze/reboot), 2–3 bundled licensed reciters,
and small/medium/large home-screen widgets fed by the same snapshot.
All existing screens, theme, and architecture are reused and connected to
the new domain — nothing is redesigned.

## Technical Context

**Language/Version**: Dart SDK ^3.5.3 (Flutter stable), Kotlin via
existing Gradle setup (compileSdk 35, targetSdk 35, minSdk =
flutter.minSdkVersion, `kotlin-android` plugin already applied).

**Primary Dependencies**:
- Existing (reuse): `flutter_bloc` (Cubits), `get_it` (DI), `go_router`,
  `shared_preferences` (storage), `intl` (dates/formatting),
  `flutter_screenutil`, `just_audio` (in-app audio),
  `home_widget` 0.9.4 (widget bridge — already a dependency),
  `equatable`.
- New (each justified in research.md): `adhan_dart ^2.0.1` (local
  astronomical calculation), `geolocator` (one-shot device location),
  `flutter_timezone` (device timezone detection). Notifications are posted
  exclusively by the native Kotlin layer — no Dart notification package
  (avoids two overlapping notification mechanisms; `POST_NOTIFICATIONS` is
  requested via the native scheduler contract).
- Native Android (Kotlin, no new Gradle plugin): AlarmManager exact
  alarms, `BOOT_COMPLETED`/`TIMEZONE_CHANGED` receivers, Adhan playback
  service, Glance widget update path — exposed to Dart through a
  MethodChannel abstraction.

**Storage**: Existing `shared_preferences` only (location, method,
reciter, notifications flag, cached prayer snapshot JSON). No new
database. City database = bundled JSON asset under `assets/json/`.

**Testing**: `flutter_test` (unit tests for calculation, state
derivation, repository, scheduler logic with fake clock; widget tests
for reused UI states), plus manual device matrix (locked/killed/Doze/
reboot/timezone) documented in quickstart.md.

**Target Platform**: Android (existing Siraty target). iOS is out of
scope for V1 of this feature.

**Project Type**: mobile-app (Flutter, feature-first Clean Architecture).

**Performance Goals**: Prayer calculation only on defined triggers
(location change, day change, timezone change, schedule rebuild, cache
invalidation). No background polling, no per-minute wake-ups, no
continuous GPS. Countdown ticks only while a screen is visible.

**Constraints**: Fully offline core calculation; adhan audio bundled
(2–3 licensed reciters); existing SharedPreferences keys stay
compatible until migration is approved; exact-alarm and notification
permission denials must degrade gracefully.

**Scale/Scope**: Single-user local app; worldwide city database
(bundled, tens of thousands of entries acceptable as asset);
5 prayer events × 2 event types × 2 days of scheduled alarms.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Protect Existing Users | ✅ PASS | Existing SharedPreferences keys untouched; the current remote-API prayer pipeline is replaced behind the same Cubit/UI contract; rollout plan + rollback = revert commit, no data migration needed (new keys are additive). |
| II. Religious Content Verified | ✅ PASS | Prayer times are astronomical calculations from a vetted library, not generated content; method/parameters fixed per region and validated against trusted references (FR-016). No AI-generated religious text. |
| III. Arabic-First, Accessible Design | ✅ PASS | All new UI reuses existing theme/components; RTL verified for names, times, countdown, widget, notifications. |
| IV. Offline Reliability & Observable Failures | ✅ PASS | Core calculation fully offline; typed failures (not silent `null`); degraded permission states surfaced to the user. |
| V. Tested, Incremental Engineering | ✅ PASS | Unit tests mandated for calculation/state/repository/scheduler with injected clock; incremental task groups via tasks.md. |
| VI. Simplicity Over Architecture | ✅ PASS | Extends existing feature-first layers; new packages each justified; no second astronomy implementation; widget reads persisted snapshot. |
| VII. AI Accelerates; Developer Owns | ✅ PASS | Ahmed reviews all output; accuracy validation matrix reviewed before release. |

No violations → Complexity Tracking section not needed.

## Project Structure

### Documentation (this feature)

```text
specs/002-prayer-times-adhan-widget/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── native-prayer-scheduler.md
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/prayer/
├── data/
│   ├── datasource/
│   │   ├── prayer_calculation_data_source.dart   # adhan_dart wrapper
│   │   └── city_database_data_source.dart        # bundled JSON city search
│   ├── models/
│   │   ├── prayer_day_model.dart                 # snapshot persistence model
│   │   └── adhan_reciter_model.dart
│   ├── repositories/
│   │   └── prayer_repository_impl.dart           # extended (existing file)
│   └── services/
│       └── location_service.dart                 # geolocator one-shot wrapper
├── domain/
│   ├── entities/
│   │   ├── prayer_time.dart                      # name, time, status
│   │   ├── prayer_day.dart
│   │   ├── prayer_location.dart
│   │   ├── prayer_event.dart                     # prayer/type/date/id
│   │   └── adhan_reciter.dart
│   ├── repositories/
│   │   └── prayer_repository.dart                # extended (existing file)
│   └── usecases/
│       ├── get_prayer_times_usecase.dart         # adapted (existing)
│       ├── get_next_prayer_usecase.dart
│       ├── set_prayer_location_usecase.dart
│       ├── refresh_prayer_schedule_usecase.dart
│       └── set_adhan_reciter_usecase.dart
├── presentation/
│   ├── cubit/
│   │   ├── azan_cubit.dart                       # extended (existing)
│   │   └── azan_state.dart                       # extended (existing)
│   ├── pages/
│   │   ├── prayer_page.dart                      # connected (existing)
│   │   └── location_picker_page.dart             # NEW: search + "use my location"
│   └── widgets/
│       └── prayer_view_body.dart                 # connected (existing)

lib/features/settings/presentation/pages/
└── settings_page.dart                            # extended (existing) — prayer section

lib/core/services/
└── prayer_scheduler_interface.dart               # Dart↔Android abstraction

android/app/src/main/kotlin/.../
├── PrayerSchedulerPlugin.kt                      # MethodChannel: schedule/cancel
├── PrayerAlarmReceiver.kt                        # fires reminder/adhan alarms
├── PrayerBootReceiver.kt                         # BOOT_COMPLETED / TIMEZONE_CHANGED
├── AdhanPlaybackService.kt                       # bundled audio playback
└── widget/                                       # Glance small/medium/large

assets/
├── json/cities.json                              # bundled worldwide city DB
└── audio/adhan/                                  # 2–3 licensed reciter files

test/features/prayer/
├── calculation/  ├── state/  ├── repository/  └── scheduler/
```

**Structure Decision**: Extend the existing feature-first
`lib/features/prayer` Clean Architecture layout (datasource/models/
repositories/domain/presentation already exist). Remote prayer data
source is retired; `prayer_remote_data_source.dart` removed once the
local pipeline is wired. Android-native pieces live in the existing
`android/app` Kotlin tree behind a `core/services` Dart interface,
keeping the domain platform-independent.

## Complexity Tracking

> Not applicable — Constitution Check has no violations.
