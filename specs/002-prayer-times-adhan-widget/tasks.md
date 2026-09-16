# Tasks: Prayer Times, Adhan, Notifications & Android Widget

**Input**: Design documents from `/specs/002-prayer-times-adhan-widget/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/native-prayer-scheduler.md, quickstart.md

**Tests**: Included — spec FR-019 mandates automated coverage for calculation, state derivation, repository, and scheduler logic.

**Organization**: Tasks are grouped by user story (spec.md priorities P1–P3) to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths per plan.md Project Structure

## Path Conventions

- Flutter/Dart: `lib/features/prayer/**`, `lib/core/**`, `test/features/prayer/**`
- Native Android: `android/app/src/main/kotlin/**`, `android/app/src/main/AndroidManifest.xml`
- Assets: `assets/json/`, `assets/audio/adhan/`

---

## Phase 1: Setup

**Purpose**: Dependencies, assets, and manifest groundwork.

- [X] T001 Add `adhan_dart ^2.0.1`, `geolocator`, `flutter_timezone` to pubspec.yaml; run `flutter pub get`; verify no version conflicts with Dart ^3.5.3 (no Dart notification package — notifications are native-only per plan.md)
- [X] T002 [P] Build and bundle the worldwide city database `assets/json/cities.json` (name ar/en, country, countryCode, lat, lon, IANA timezone) from a public-domain source; register asset folder in pubspec.yaml
- [X] T003 [P] Place 2–3 licensed Adhan audio files in `assets/audio/adhan/` and register the folder in pubspec.yaml (requires Ahmed's confirmed licensed files — see plan open item)
- [X] T004 [P] Add manifest permissions `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`, `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` to android/app/src/main/AndroidManifest.xml (no `USE_EXACT_ALARM` — see research.md R5)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities and calculation core that every story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T005 [P] Create domain entities in lib/features/prayer/domain/entities/: `prayer_time.dart` (key enum incl. sunrise with isPrayer=false, time, derived status), `prayer_day.dart`, `prayer_location.dart`, `prayer_event.dart`, `adhan_reciter.dart`, `calculation_method_setting.dart` per data-model.md
- [X] T006 [P] Create `lib/features/prayer/data/datasource/prayer_calculation_data_source.dart`: adhan_dart wrapper taking PrayerLocation + CalculationMethodSetting → PrayerDay for any date; country-code → method defaults table (research.md R1); location IANA timezone honored
- [X] T007 [P] Create `lib/core/services/prayer_scheduler_interface.dart`: Dart abstraction for scheduleEvents / cancelAllPrayerEvents / canScheduleExactAlarms / requestExactAlarmPermission / updateWidget per contracts/native-prayer-scheduler.md
- [X] T008 [P] Create `lib/features/prayer/data/datasource/city_database_data_source.dart`: load `assets/json/cities.json` once, Arabic/English prefix search, nearest-city (haversine) lookup for coordinates
- [X] T009 Write calculation unit tests in test/features/prayer/calculation/prayer_calculation_data_source_test.dart: Egyptian parameters (19.5°/17.5°/Shafi), ordering fajr<sunrise<…<isha, timezone correctness (must FAIL first, then pass with T006)

**Checkpoint**: Entities, calculation core, city search, and scheduler abstraction ready.

---

## Phase 3: User Story 1 - Accurate Prayer Times for My Location (Priority: P1) 🎯 MVP

**Goal**: Offline worldwide prayer times with status, countdown, and location setup (auto-detect or city search).

**Independent Test**: Grant/deny location permission on first launch in airplane mode; verify times, statuses, countdown on existing Home and Prayer screens (quickstart.md "Automated validation" + offline manual checks).

### Tests for User Story 1

- [X] T010 [P] [US1] State-derivation tests in test/features/prayer/state/prayer_status_test.dart: before-fajr, between, current, after-Isha→tomorrow's fajr, midnight transition, sunrise excluded (write first, must FAIL)
- [X] T011 [P] [US1] Repository tests in test/features/prayer/repository/prayer_repository_test.dart: save/load location, method, snapshot; stale snapshot replacement (write first, must FAIL)

### Implementation for User Story 1

- [X] T012 [US1] Create `lib/features/prayer/data/services/location_service.dart`: geolocator one-shot detection + permission handling; coordinates → nearest city + timezone via T008; no continuous tracking
- [X] T013 [US1] Create persistence models `prayer_day_model.dart`, and snapshot/setting serializers in lib/features/prayer/data/models/ with SharedPreferences keys `prayer.*` (namespaced, additive — existing keys untouched)
- [X] T014 [US1] Extend `lib/features/prayer/domain/repositories/prayer_repository.dart` + `prayer_repository_impl.dart`: replace remote-API pipeline with local calculation via T006, snapshot persistence (today+tomorrow), settings (method/madhab override), typed errors (no silent null)
- [X] T015 [US1] Add use cases in lib/features/prayer/domain/usecases/: `get_prayer_times_usecase.dart` (adapt existing), `get_next_prayer_usecase.dart`, `set_prayer_location_usecase.dart`
- [X] T016 [US1] Extend `azan_cubit.dart`/`azan_state.dart` in lib/features/prayer/presentation/cubit/: load from repository, derived statuses, next prayer, live countdown (visible-screen ticker only, injected clock)
- [X] T017 [US1] Create `lib/features/prayer/presentation/pages/location_picker_page.dart`: one-tap "use my current location" + city search (T008), Arabic RTL, existing design tokens; register route in lib/app/router/app_router.dart
- [X] T018 [US1] Connect existing `prayer_page.dart`, `prayer_view_body.dart`, and Home prayer widgets (lib/features/home/presentation/widgets/) to AzanCubit data — no visual redesign; first-launch location prompt wired to T012
- [X] T019 [US1] Extend `lib/app/di/service_locator.dart`: register calculation/city datasources, location service, repository (follow existing GetIt pattern)
- [X] T020 [US1] Remove retired `lib/features/prayer/data/datasource/prayer_remote_data_source.dart` and unused Dio prayer code after UI is served locally
- [X] T021 [US1] Accuracy validation matrix: add test/features/prayer/calculation/accuracy_validation_test.dart with documented expected data — V1 validated regions: Egypt (Egyptian General Authority of Survey) and KSA (Umm al-Qura), ≥5 cities × ≥4 seasonal dates each; other regions rely on library presets + user override (research.md R10); investigate — never offset — discrepancies

**Checkpoint**: MVP — accurate offline prayer times, statuses, countdown, location setup all working on existing UI.

---

## Phase 4: User Story 2 - Prayer Reminders and Adhan (Priority: P2)

**Goal**: 10-minute reminders + exact-time Adhan with 2–3 reciters, surviving background/kill/lock/reboot, with graceful permission degradation.

**Independent Test**: Schedule a prayer minutes away; background/kill/lock/reboot the device; verify reminder at −10 min and Adhan on time; toggle notifications/reciter in Settings (quickstart.md manual matrix).

### Tests for User Story 2

- [X] T022 [P] [US2] Scheduler-logic tests in test/features/prayer/scheduler/prayer_event_planner_test.dart with fake clock + fake scheduler interface: reminder=−10min, adhan=on time, sunrise excluded, deterministic IDs, duplicate prevention, cancel-on-location-change/disable (write first, must FAIL)

### Implementation for User Story 2

- [X] T023 [US2] Create native `android/app/src/main/kotlin/.../PrayerSchedulerPlugin.kt`: MethodChannel `siraty/prayer_scheduler` implementing contracts/native-prayer-scheduler.md (exact alarms via setExactAndAllowWhileIdle, canScheduleExactAlarms check, inexact fallback, typed error codes)
- [X] T024 [P] [US2] Create native `PrayerAlarmReceiver.kt`: REMINDER → silent notification (tap → Prayer screen deep link); ADHAN → notification + MediaPlayer playback of bundled reciter asset; notification channels `siraty_prayer_reminders` / `siraty_adhan`
- [X] T025 [P] [US2] Create native `PrayerBootReceiver.kt` + manifest registration: BOOT_COMPLETED / TIMEZONE_CHANGED / MY_PACKAGE_REPLACED → reschedule remaining events + update widget from persisted snapshot, no Flutter UI launch
- [X] T026 [P] [US2] Create native `AdhanPlaybackService.kt` for background Adhan audio; foreground (app open) path via existing just_audio reading the same reciter setting
- [X] T027 [US2] Create Dart-side event planner + `RefreshPrayerScheduleUseCase` in lib/features/prayer/domain/usecases/ + MethodChannel implementation of T007 in lib/core/services/: build today+tomorrow events, cancel-then-schedule with deterministic IDs, rebuild triggers per data-model.md state transitions
- [X] T028 [US2] Create `adhan_reciter_model.dart` in lib/features/prayer/data/models/ + reciter registry validated against actual assets (missing asset → not exposed)
- [X] T029 [US2] Extend the existing Settings screen at lib/features/settings/presentation/pages/settings_page.dart (do not rebuild): prayer section — notifications toggle, current city + change (opens T017 picker), reciter selection, calculation method / Asr madhab override; wire `SetAdhanReciterUseCase` and notification enable/disable to T027 rebuild logic
- [X] T030 [US2] Handle notification runtime permission (POST_NOTIFICATIONS, API 33+) contextually via a native `requestNotificationPermission()` method on the scheduler channel (contracts/native-prayer-scheduler.md); denial keeps all non-notification functionality (spec FR-010)

**Checkpoint**: Reminders and Adhan work across the full device-state matrix.

---

## Phase 5: User Story 3 - Home-Screen Widget (Priority: P3)

**Goal**: Small/medium/large widgets fed by the persisted snapshot, correct with app killed, updating at prayer boundaries without per-minute wake.

**Independent Test**: Add each widget size, kill app, reboot, change city, cross a day boundary; verify data matches app and tap opens existing Prayer screen (quickstart.md widget checks).

### Implementation for User Story 3

- [X] T031 [US3] Implement snapshot → home_widget shared-storage writer in lib/ (reuse existing home_widget 0.9.4 dependency): write on every recalculation trigger (data-model.md state transitions)
- [X] T032 [P] [US3] Implement native widget provider(s) in android/app/src/main/kotlin/.../widget/: small (next prayer + countdown), medium (+ upcoming prayers), large (location + full list + statuses) — RemoteViews or Glance per research.md R6, Arabic RTL, existing visual identity
- [X] T033 [US3] Wire widget tap → deep link to existing Prayer screen route (no new screen); update strategy = prayer boundaries + app open + data changes, never per-minute
- [X] T034 [US3] Extend T025 boot receiver and T027 rebuild flow to call the widget update path

**Checkpoint**: All three stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, validation, documentation.

- [X] T035 [P] Verify Arabic RTL rendering across prayer names, times, countdown, location, Settings, notifications, and widgets; fix any LTR hardcoding
- [X] T036 [P] Verify accessibility and text scaling (up to 200%) on new Settings section and location picker
- [X] T037 Run full quickstart.md validation: `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and the manual device matrix
- [X] T038 Document the final implementation report (source doc §65): files changed, dependencies + why, permissions, native components, calculation config, accuracy results, scheduling behavior, widget behavior, tests, platform limitations
- [X] T039 Code cleanup: remove dead remote-API code, confirm no duplicate repositories/Cubits, lint-clean

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately. T003 blocked on Ahmed's licensed audio files; proceed with others.
- **Phase 2 (Foundational)**: Depends on T001/T002; BLOCKS all user stories.
- **Phase 3 (US1)**: Depends on Phase 2.
- **Phase 4 (US2)**: Depends on Phase 2; consumes US1's repository/cubit (T014/T016) for scheduling triggers.
- **Phase 5 (US3)**: Depends on Phase 2 + US1 snapshot (T014) + US2 rebuild flow (T027).
- **Phase 6 (Polish)**: After all desired stories complete.

### Within Each User Story

- Tests first (must FAIL), then models → services → UI/integration.
- Story complete and independently validated before the next priority.

### Parallel Opportunities

- Phase 1: T002, T003, T004 in parallel after T001.
- Phase 2: T005–T008 fully parallel; T009 after T006.
- Phase 3: T010/T011 tests parallel; models T012/T013 parallel.
- Phase 4: T024/T025/T026 native components parallel after T023.
- Phase 5: T032 widget sizes parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) — minus audio if not yet supplied
2. Complete Phase 2 (Foundational)
3. Complete Phase 3 (US1)
4. **STOP and VALIDATE**: offline accurate times on existing UI
5. Demo if ready

### Incremental Delivery

1. Setup + Foundational → core ready
2. US1 → MVP (accurate offline prayer times)
3. US2 → reminders + Adhan
4. US3 → widgets
5. Polish → quality gates + report

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to spec.md user story
- Commit after each task or logical group; stop at any checkpoint to validate
- Inspect-first rule (source doc §2): before every task touching existing files, read the current implementation and reuse it
- T003 requires Ahmed's licensed Adhan audio + reciter names (plan open item)
