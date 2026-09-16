# Feature Specification: Prayer Times, Adhan, Notifications & Android Widget

**Feature Branch**: `002-prayer-times-adhan-widget`

**Created**: 2026-09-07

**Status**: Draft

**Input**: User description: "based on siraty-prayer-times-spec.md" — complete
production prayer-time system for Siraty: offline prayer-time calculation,
location selection, prayer status/countdown, reminders, Adhan with multiple
reciters, reliable Android background scheduling, and home-screen widgets.

## Clarifications

### Session 2026-09-07

- Q: Where does city search data come from? → A: Bundled offline city database (Egypt-focused, with coordinates + timezone).
- Q: How many Adhan reciters in V1? → A: 2–3 licensed bundled reciters.
- Q: Reminder notification tap/sound behavior? → A: Silent text reminder; tap opens existing Prayer screen.
- Q: Geographic scope? → A: Worldwide, not Egypt-only. Calculation method auto-selected per country (Egyptian method in Egypt), with user override available.
- Q: How is location changed later? → A: One-tap "use my current location" (auto-detect) OR city search — user never has to browse country/city lists manually.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accurate Prayer Times for My Location (Priority: P1)

As a Siraty user, when I first open the app I am asked for location
permission. If I grant it, the app detects my city, shows today's six daily
times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) using the standard
calculation method for my country (the Egyptian General Authority of Survey
method in Egypt), marks each as passed/current/upcoming,
and shows a live countdown to the next prayer. If I deny permission, the app
stays fully usable and I can pick my city by searching for it by name. All of
this works with no internet connection.

**Why this priority**: Prayer times are the core value of the app; without
accurate, location-correct times nothing else in this feature matters.

**Independent Test**: Grant or deny location permission on first launch, verify
times, statuses, and countdown render on the existing Home and Prayer screens
in airplane mode.

**Acceptance Scenarios**:

1. **Given** a first launch with location permission granted, **When** the
   Prayer screen opens, **Then** today's times for the detected city are shown,
   each with passed/current/upcoming status and a countdown to the next prayer.
2. **Given** location permission denied, **When** the user searches and selects
   a city, **Then** all prayer data updates to that city and every feature
   except automatic detection keeps working. If permission is later granted,
   the user can update their city in one tap via "use my current location".
3. **Given** the device is offline, **When** the user opens the app or changes
   city, **Then** today's and tomorrow's times are still calculated and shown.
4. **Given** it is after Isha, **When** the user views the next-prayer card,
   **Then** it shows tomorrow's Fajr, not yesterday's or an empty state.
5. **Given** the user changes the device timezone, **When** the app next runs,
   **Then** times are recalculated with the selected location's timezone and
   alarms are rescheduled.

---

### User Story 2 - Prayer Reminders and Adhan (Priority: P2)

As a user, I receive a notification 10 minutes before each of the five prayers
(Fajr, Dhuhr, Asr, Maghrib, Isha) and the Adhan audio plays exactly at prayer
time — even when the app is in the background, the screen is locked, the app
process has been killed, or the phone was rebooted. Sunrise never triggers a
reminder or Adhan. I can enable/disable notifications and choose between
bundled Adhan reciters from Settings.

**Why this priority**: Notifications and Adhan deliver the daily practical
value of prayer times, but depend on Story 1's calculation being correct.

**Independent Test**: Set a prayer a few minutes away, background/kill/lock
the app, and verify the reminder fires 10 minutes before and the Adhan at the
exact time; toggle notifications and reciter in Settings and verify behavior.

**Acceptance Scenarios**:

1. **Given** notifications enabled and the app backgrounded or killed,
   **When** a prayer time minus 10 minutes arrives, **Then** a reminder
   notification appears.
2. **Given** the same conditions, **When** the prayer time arrives, **Then**
   the selected reciter's Adhan plays.
3. **Given** the device reboots, **When** it starts up again, **Then** prayer
   alarms are restored without the user opening the app.
4. **Given** the user disables notifications, **When** settings are saved,
   **Then** all prayer alarms are cancelled while times, UI, and widget keep
   working.
5. **Given** the user selects a different reciter, **When** the choice is
   saved, **Then** future Adhan events use the new reciter without duplicate
   alarms and without changing prayer times.
6. **Given** notification permission or exact-alarm permission is denied,
   **When** the app runs, **Then** nothing crashes, prayer times/UI/widget
   remain functional, and the user is given an appropriate path to enable the
   missing access.

---

### User Story 3 - Home-Screen Widget (Priority: P3)

As a user, I can add a Siraty widget to my Android home screen in small
(next prayer, time, countdown), medium (plus several upcoming prayers), or
large (location, next prayer, countdown, full today list with status) sizes.
The widget shows correct data even when the app process is not running, uses
the same prayer data as the app (never its own calculation), and updates at
prayer boundaries without draining the battery. Tapping it opens the existing
Prayer screen.

**Why this priority**: The widget is a convenience surface; valuable but fully
dependent on Stories 1–2.

**Independent Test**: Add each widget size, kill the app, change city, reboot,
and verify data correctness and updates.

**Acceptance Scenarios**:

1. **Given** the widget added in any size, **When** the app process is not
   running, **Then** the widget still shows correct next prayer, countdown,
   and (for medium/large) today's times.
2. **Given** the user changes city or a new day begins, **When** prayer data
   is recalculated, **Then** the widget reflects the new data.
3. **Given** the user taps the widget, **When** it opens, **Then** the
   existing Prayer screen is shown (no new screen).
4. **Given** any size, **When** rendered, **Then** the widget uses Siraty's
   Arabic RTL visual identity and never refreshes every minute just to tick a
   countdown.

### Edge Cases

- Location permission denied → manual city search remains; app never breaks.
- Device location unavailable → fall back to last saved location.
- No saved location at all → location-selection UI is shown.
- Exact-alarm permission unavailable → graceful degradation with user guidance.
- Notification permission denied (Android 13+) → all other functionality kept.
- Selected reciter's audio asset missing/unusable → reciter not exposed or
  Adhan not scheduled; issue logged; no broken Adhan.
- Corrupt/missing cached prayer data → recalculate locally.
- Device reboot → alarms and widget restored automatically.
- Timezone or DST change → recalculate, reschedule, refresh widget.
- Around midnight after Isha → next prayer is tomorrow's Fajr (correct date
  handling).
- Scheduling called repeatedly → deterministic alarm IDs prevent duplicates.
- Sunrise is never treated as a prayer (no reminder, no Adhan, no prayer
  status behavior).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST calculate all six daily times locally/offline
  for today and tomorrow, worldwide (not Egypt-only). The calculation method
  MUST be auto-selected per country/region — Egyptian General Authority of
  Survey (Fajr 19.5°, Isha 17.5°, Asr Shafi) as the default for Egypt, and
  each region's recognized standard method elsewhere (e.g., Umm al-Qura,
 Muslim World League, ISNA, Karachi) — with zero manual offsets. The user MUST
  be able to override the calculation method and Asr madhab from Settings.
- **FR-002**: The system MUST derive each prayer's status (PASSED / CURRENT /
  UPCOMING) and the next prayer from the current time, never from a persisted
  value; after Isha the next prayer MUST be tomorrow's Fajr.
- **FR-003**: The countdown MUST be computed as next-prayer time minus current
  time, updating only while visible, without continuous background execution.
- **FR-004**: On first launch the system MUST request location permission; if
  granted it MUST detect the location, resolve it to a human-readable city and
  its timezone, save it, and refresh all prayer data. If denied, the app MUST
  remain fully usable via manual city search.
- **FR-005**: The system MUST allow changing location at any time with minimal
  effort, by either (a) a one-tap "use my current location" action that
  auto-detects the device location and resolves it to city, country,
  coordinates, and timezone, or (b) searching a city by name (never manual
  latitude/longitude) against a bundled offline worldwide city database. Both
  paths MUST then deterministically recalculate, refresh UI and widget, and
  reschedule alarms.
- **FR-006**: The system MUST NOT perform continuous background GPS tracking
  in V1; location changes are explicit user actions — first-launch detection,
  one-tap "use my current location", or manual city search.
- **FR-007**: The system MUST schedule, for each of the five prayers only, a
  silent reminder notification at prayer time minus a fixed 10 minutes and an
  Adhan event exactly at prayer time; Sunrise MUST receive neither. Tapping a
  prayer notification MUST open the existing Prayer screen (no new screen);
  only the Adhan event carries audio.
- **FR-008**: Scheduled events MUST use the platform's exact-alarm
  infrastructure with deterministic alarm IDs (derived from date + prayer +
  event type) so repeated scheduling never creates duplicates and cancellation
  is reliable; polling, periodic timers, and one-minute background loops MUST
  NOT be used.
- **FR-009**: Events MUST fire when the app is foregrounded, backgrounded,
  screen-locked, killed, or after device reboot; a boot receiver MUST restore
  schedules from persisted location/settings without the user opening the app.
- **FR-010**: If exact-alarm or notification permission is unavailable, the
  system MUST degrade gracefully: no crash, no false claims of exactness,
  prayer times/UI/widget keep working, and the user is guided to enable access
  where the platform allows.
- **FR-011**: Adhan audio MUST be bundled offline assets; V1 MUST ship with
  2–3 licensed reciters, and only reciters with valid local audio MUST be
  listed; changing reciter MUST persist the choice and apply to future Adhan
  events without disturbing prayer times or duplicating alarms.
- **FR-012**: The system MUST provide small, medium, and large responsive
  home-screen widgets that read the same persisted prayer snapshot as the app,
  never calculate prayer times independently, update on data/day changes and
  prayer boundaries (not per-minute), and open the existing Prayer screen on
  tap.
- **FR-013**: Home, Prayer screen, Settings, notifications, scheduler, and
  widget MUST all consume one single prayer-time source of truth; duplicate
  calculation implementations MUST NOT exist in the Flutter or native layers.
- **FR-020**: The Settings screen MUST be extended (not rebuilt) with a
  prayer section covering notification enable/disable, current city with
  change option, reciter selection, and calculation method / Asr madhab
  override, using the existing design language.
- **FR-014**: The system MUST persist selected location, coordinates,
  timezone, city/country, notification setting, selected reciter, and a cached
  prayer snapshot using the app's existing storage — no new database.
- **FR-015**: The system MUST use the selected location's timezone for all
  calculations regardless of device timezone, and MUST recalculate and
  reschedule when the device timezone changes.
- **FR-016**: Prayer-time accuracy MUST be validated against trusted
  references for each supported region (including the Egyptian General
  Authority of Survey for Egypt) across multiple cities and dates covering
  all seasons; any discrepancy MUST be investigated and documented
  (coordinates, method, madhab, timezone, date, expected vs calculated,
  difference, cause) rather than hidden behind arbitrary offsets.
- **FR-017**: All user-facing elements (prayer names, times, countdown,
  location, settings, notifications, widget) MUST render correctly in
  Arabic RTL, reusing existing localization and design conventions.
- **FR-018**: The implementation MUST reuse the existing screens, theme,
  components, architecture conventions, and dependency-injection setup;
  duplicate screens, Cubits, repositories, or unrelated dependencies MUST NOT
  be introduced.
- **FR-019**: Calculation, state-derivation, repository, and scheduler logic
  MUST be covered by automated tests (parameters, ordering, known cities,
  multiple dates, timezone, midnight transition, sunrise exclusion, snapshot
  save/load/replace, reminder timing, cancellation, deterministic IDs,
  duplicate prevention).

### Key Entities *(include if feature involves data)*

- **PrayerTime**: One daily time slot — prayer name (of the six, with Sunrise
  marked non-prayer), time, derived status.
- **PrayerDay**: All six times for a calendar day at a location, plus the
  next-day link used after Isha.
- **PrayerLocation**: Selected location — city name, country, latitude,
  longitude, timezone.
- **PrayerEvent**: A scheduled occurrence — prayer, event type (reminder |
  adhan), date, scheduled time, deterministic alarm ID.
- **AdhanReciter**: A selectable reciter — id, display name, bundled audio
  reference; only exposed when valid audio exists.
- **Prayer Snapshot (cached)**: Persisted today/tomorrow times that both the
  app UI and the widget read.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Calculated times match each region's trusted reference for at
  least 5 cities per validated region across at least 4 seasonal dates, with
  every remaining difference documented and explained by an identified cause.
- **SC-002**: Prayer events (reminder at −10 min, Adhan at time) fire on time
  in 100% of tested foreground, background, locked, killed, Doze, and
  post-reboot scenarios on real Android devices.
- **SC-003**: All prayer calculation and city selection works with the device
  fully offline.
- **SC-004**: The user can complete first-launch location setup (grant or deny
  + manual selection) in under 1 minute.
- **SC-005**: Widget data matches the in-app data in 100% of tested states
  (app running, killed, rebooted, city changed, new day).
- **SC-006**: Prayer calculations run only on defined triggers (location
  change, new day, timezone change, schedule rebuild) — no measurable battery
  impact from background polling or per-minute wake-ups.
- **SC-007**: All automated quality gates pass with no new errors, and all
  new logic has the required test coverage.
- **SC-008**: Users with denied location, notification, or exact-alarm
  permissions can still view correct prayer times, statuses, countdown, and
  widget (degraded only in the denied capability).

## Assumptions

- The source requirements document (`siraty-prayer-times-spec.md`) is the
  authoritative, detailed input; this spec is its user-value formulation.
- The app supports users worldwide, not Egypt-only. The calculation method is
  auto-selected per country/region (Egyptian General Authority of Survey in
  Egypt) and can be overridden by the user from Settings.
- Reminder lead time is fixed at 10 minutes; no user-configurable duration,
  and no user-editable prayer-time offsets in V1.
- A local calculation library (adhan_dart ^2.0.1, or the closest version
  compatible with the repo's constraints) is used — never an online
  prayer-times API for core calculation.
- The existing Siraty UI, screens, theme, architecture, storage, and DI are
  reused and extended; the source document's "inspect first → reuse first"
  rule governs implementation.
- City search uses a bundled offline worldwide city database (clarified
  2026-09-07); no online geocoding in V1.
- The Android widget uses a Glance version compatible with the current
  Gradle/Kotlin setup; the toolchain is not upgraded solely for the widget.
- Full-screen intents are not used as an Adhan workaround; Android 14+
  restrictions are respected and documented.
- All bundled Adhan audio is properly licensed; reciters without valid assets
  are not shown.
- Accuracy validation in V1 covers Egypt (Egyptian General Authority of
  Survey) and KSA (Umm al-Qura) as validated-reference regions; other
  regions use standard method presets with user override, with the
  validated list expandable post-V1.
