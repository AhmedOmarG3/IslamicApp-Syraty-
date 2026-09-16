# Data Model: Prayer Times, Adhan, Notifications & Android Widget

**Date**: 2026-09-07 | **Spec**: [spec.md](spec.md)

All entities live in `lib/features/prayer/domain/entities/`; persistence
models in `data/models/` map to/from SharedPreferences JSON. Field types
are conceptual (implementation may adjust to project conventions).

## Entities

### PrayerTime

| Field | Type | Notes |
|---|---|---|
| key | enum { fajr, sunrise, dhuhr, asr, maghrib, isha } | `isPrayer` = true except sunrise |
| time | DateTime (location-local) | |
| status | enum { passed, current, upcoming } | **Derived**, never persisted |

Validation: fajr < sunrise < dhuhr < asr < maghrib < isha (same day).

### PrayerDay

| Field | Type | Notes |
|---|---|---|
| date | DateTime (location-local calendar day) | |
| location | PrayerLocation reference | |
| times | List\<PrayerTime\> (6 entries) | ordered |

Derived (not stored): nextPrayer (before fajr → today's fajr; after isha →
**tomorrow's** fajr), currentPrayer.

### PrayerLocation

| Field | Type | Notes |
|---|---|---|
| cityName | String (Arabic display) | |
| countryName | String | |
| countryCode | String (ISO 2) | drives method auto-selection |
| latitude / longitude | double | |
| timezone | String (IANA, e.g. "Africa/Cairo") | used for all calculation |

Identity: (latitude, longitude) rounded to 4 dp ≈ same location.

### CalculationMethodSetting

| Field | Type | Notes |
|---|---|---|
| method | enum { auto, egyptian, ummAlQura, muslimWorldLeague, isna, karachi, … } | default `auto` |
| asrMadhab | enum { shafi, hanafi } | default shafi |

Validation: no offsets exist in the model (spec prohibits them).

### PrayerEvent

| Field | Type | Notes |
|---|---|---|
| prayer | enum (5 prayers; sunrise excluded) | |
| eventType | enum { reminder, adhan } | |
| date | DateTime | |
| scheduledAt | DateTime | reminder = time − 10 min; adhan = time |
| alarmId | int (deterministic) | hash(date, prayer, eventType) |

Deterministic-ID rule: same (date, prayer, eventType) ⇒ same alarmId ⇒
re-scheduling replaces, never duplicates.

### AdhanReciter

| Field | Type | Notes |
|---|---|---|
| id | String | |
| displayName | String (Arabic) | |
| assetPath | String | bundled audio file |

Registry validated at startup: reciters whose asset is missing are not
exposed (FR-011).

### PrayerSnapshot (persisted)

| Field | Type | Notes |
|---|---|---|
| today | PrayerDay model | |
| tomorrow | PrayerDay model | enables post-Isha next-prayer + pre-scheduling |
| location | PrayerLocation model | |
| generatedAt | DateTime | for staleness checks |
| method | CalculationMethodSetting | |

Single source of truth for: Home, Prayer screen, scheduler, and widget
(written additionally to home_widget shared storage).

## State transitions (scheduler lifecycle)

```
App start / location change / day change / timezone change /
settings change / reboot / invalid cache
        ↓
Load persisted location+settings → calculate today+tomorrow
        ↓
Persist snapshot (+ widget storage) → cancel existing Siraty alarms
        ↓
Schedule remaining today + tomorrow events (reminder −10min, adhan on time)
```

Notifications disabled ⇒ cancel all events, keep snapshot/UI/widget.
Reciter changed ⇒ persist; future adhan events play new reciter (rebuild
adhan alarms only if the payload embeds reciter).

## Storage keys (SharedPreferences, new — additive)

| Key | Value |
|---|---|
| `prayer.location` | PrayerLocation JSON |
| `prayer.calcMethod` / `prayer.asrMadhab` | setting values |
| `prayer.notificationsEnabled` | bool |
| `prayer.reciterId` | String |
| `prayer.snapshot` | PrayerSnapshot JSON |

Existing keys are untouched (Constitution I).

## Bundled data assets

- `assets/json/cities.json` — worldwide cities: name (ar/en), country,
  countryCode, lat, lon, timezone.
- `assets/audio/adhan/<reciter-id>.mp3` — 2–3 licensed reciter files.
