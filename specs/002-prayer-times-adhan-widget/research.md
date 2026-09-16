# Research: Prayer Times, Adhan, Notifications & Android Widget

**Date**: 2026-09-07 | **Status**: All NEEDS CLARIFICATION resolved

## R1. Prayer calculation engine

- **Decision**: `adhan_dart ^2.0.1` for all local astronomical calculation.
- **Rationale**: Source document mandates it; pure Dart, offline, supports
  CalculationMethod presets needed (Egyptian, UmmAlQura, MuslimWorldLeague,
  NorthAmerican, Karachi, etc.), madhab selection (Shafi/Hanafi), and
  high-latitude rules. No network calls. Compatible with Dart SDK ^3.5.3.
- **Alternatives considered**: Aladhan API (rejected — online, violates
  offline requirement); hand-rolled astronomy (rejected — unverified
  religious-calculation risk); `salat` package (smaller ecosystem,
  fewer method presets).
- **Method auto-selection**: map country code → CalculationMethod with a
  defaults table (EG → Egyptian 19.5°/17.5°/Shafi; SA → Umm al-Qura;
  US/CA → ISNA; PK/IN/BD → Karachi; EU/UK → MWL; fallback → MWL). User
  override persisted in SharedPreferences.

## R2. Location detection

- **Decision**: `geolocator` for one-shot device location (first launch and
  the one-tap "use my current location" action). Never continuous tracking.
- **Rationale**: De-facto standard, handles Android permission prompts,
  supports `getLastKnownPosition` fallback for fast/offline detection.
  Location permission denial falls back to manual city search only.
- **Alternatives considered**: `location` package (less robust permission
  API); platform channels hand-rolled (unjustified complexity).
- **City resolution**: detected coordinates → nearest city in the bundled
  city database (haversine distance) → city name + country + timezone.
  If no database match, use coordinates directly with device timezone as
  best-effort and label it by coordinates in Arabic.

## R3. City database (offline search)

- **Decision**: Bundled JSON asset (`assets/json/cities.json`) of world
  cities with name (Arabic + English), country, country code, lat, lon,
  IANA timezone. Sourced from a public-domain dataset (e.g., GeoNames
  cities500/simplemaps free tier), curated at build time.
- **Rationale**: Works fully offline, no API key, no network failure mode;
  satisfies the "search city, never coordinates" requirement worldwide.
- **Alternatives considered**: Online geocoding (rejected — offline
  requirement); shipping full GeoNames dump (rejected — bundle size);
  SQLite city DB (rejected — new storage dependency; JSON loaded once at
  first search and cached in memory is sufficient for ~10–50k rows with
  prefix search).

## R4. Timezone handling

- **Decision**: Selected location carries an IANA timezone string (from the
  city database entry, or `flutter_timezone` device timezone for
  GPS-detected coordinates). Calculations use the location timezone via
  `package:timezone`; device `TIMEZONE_CHANGED` broadcast triggers
  recalculation + rescheduling.
- **Rationale**: `adhan_dart` date components need explicit timezone
  coordinates; avoids the "Egypt time on a foreign device timezone" bug.
- **Alternatives considered**: assuming device timezone (rejected —
  spec FR-015 forbids it).
- **Note**: `timezone` package comes as a transitive dependency of
  `adhan_dart`; verify at implementation and add explicitly only if needed.

## R5. Notifications & Adhan scheduling

- **Decision**: Native Kotlin implementation exposed via a single
  MethodChannel (`prayer_scheduler`): AlarmManager `setExactAndAllowWhileIdle`
  for REMINDER (prayer − 10 min, silent notification) and ADHAN (exact
  prayer time, notification + `MediaPlayer` bundled-asset playback).
  Deterministic alarm IDs = hash of (date, prayer, eventType).
  Receivers: `PrayerAlarmReceiver` (fires events),
  `PrayerBootReceiver` (BOOT_COMPLETED + TIMEZONE_CHANGED → reschedule
  from persisted snapshot), notification channels for reminder vs adhan.
- **Rationale**: Source document mandates native exact alarms; a
  MethodChannel behind a Dart interface keeps the domain platform-free
  (Constitution VI) while `flutter_local_notifications` alone cannot
  guarantee exact inexact-tolerant firing when the process is killed.
- **Alternatives considered**: `android_alarm_manager_plus` (wraps the same
  API but boot-receiver and audio still need native code — two overlapping
  mechanisms, rejected); `workmanager` (not exact, rejected);
  `Timer.periodic`/`Future.delayed` (explicitly forbidden).
- **Permission matrix**:
  - `SCHEDULE_EXACT_ALARM`: check `canScheduleExactAlarms()` before
    scheduling; on denial, fall back to inexact alarms + surface guidance
    to the user. Do NOT add `USE_EXACT_ALARM` (Play policy risk for
    non-calendar apps; documented limitation).
  - `POST_NOTIFICATIONS` (API 33+): contextual request; denial keeps all
    other functionality.
  - `ACCESS_COARSE/FINE_LOCATION`: only for one-shot detection.
- **Foreground Adhan**: when app is open, Adhan may route through existing
  `just_audio`; when backgrounded/killed, native `MediaPlayer` in the
  receiver/service. Both read the same reciter setting.

## R6. Widget

- **Decision**: Keep existing `home_widget` 0.9.4 dependency as the
  Dart↔widget data/update bridge; write the persisted snapshot (JSON via
  home_widget storage) on every recalculation; implement the widget UI in
  native Kotlin. If the existing Android view system is simpler for the
  current Gradle setup, use classic RemoteViews; adopt Glance only if its
  version is compatible without toolchain changes.
- **Rationale**: `home_widget` is already a dependency (Constitution VI:
  reuse first); it handles cross-process data sharing and update triggers.
  Source doc allows Glance but forbids toolchain upgrades for it.
- **Alternatives considered**: pure Glance with its own data layer
  (rejected — duplicate bridge); updating every minute for countdown
  (rejected — battery; update at prayer boundaries and on app open).
- **Sizes**: Small (next prayer + countdown), Medium (+ 2–3 upcoming),
  Large (location + full day list + statuses). Tap → deep link to existing
  Prayer screen route.

## R7. Adhan reciters & audio

- **Decision**: Ship 2–3 reciters as bundled, licensed audio assets under
  `assets/audio/adhan/`. Reciter registry is a Dart list validated at
  startup against actual asset existence — missing assets are excluded
  from Settings.
- **Rationale**: Spec FR-011; offline requirement; avoids broken Adhan.
- **Alternatives considered**: runtime download (rejected — offline +
  licensing); more reciters (bundle size).
- **Open item for Ahmed**: supply/confirm the licensed audio files and
  reciter display names before the audio tasks run.

## R8. Persistence

- **Decision**: SharedPreferences (existing) with new namespaced keys
  (`prayer.location.*`, `prayer.settings.*`, `prayer.snapshot.*`), plus
  home_widget's shared storage for the widget snapshot. Existing
  last-read/Quran keys untouched.
- **Rationale**: Constitution I & the spec forbid a new database; snapshot
  is a small JSON document.
- **Alternatives considered**: Hive/SQLite (rejected — new dependency).

## R9. Sunrise handling

- **Decision**: Sunrise is calculated and displayed as an astronomical
  time only — excluded from prayer status semantics, reminders, Adhan, and
  the five-prayer event scheduling.
- **Rationale**: Spec FR-007; religious correctness.

## R10. Accuracy validation strategy

- **Decision**: Build a validation matrix (city × date × six times)
  comparing `adhan_dart` output against trusted references. **V1 validated
  regions: Egypt (Egyptian General Authority of Survey) and KSA (Umm
  al-Qura official sources)** — ≥5 cities × ≥4 seasonal dates each. Other
  regions use the library's standard method presets with user override;
  expanding the validated-reference list is post-V1. Run as a Dart test
  suite with documented expected data; any discrepancy investigated
  (coordinates, method, madhab, timezone, DST, rounding) — never offset.
- **Rationale**: FR-016 / SC-001; Constitution II.
- **Alternatives considered**: eyeballing a single city/day (rejected —
  explicitly insufficient).

All Technical Context unknowns resolved. No NEEDS CLARIFICATION remains.
