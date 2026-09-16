# Siraty — Prayer Times, Adhan, Notifications & Android Widget

## 1. Objective

Implement a complete, production-ready prayer-time system inside the existing Siraty Flutter application.

The feature must cover:

- Accurate local prayer-time calculation.
- First-launch location permission.
- Automatic location detection through device location when permission is granted.
- Manual location selection by searching for a city.
- Offline prayer-time calculation.
- Egyptian calculation method as the default for Egypt.
- Prayer status: passed / current / upcoming.
- Next-prayer countdown.
- Prayer notifications 10 minutes before each prayer.
- Adhan exactly at prayer time.
- Multiple selectable Adhan reciters using bundled local audio.
- Android background/closed/screen-locked/reboot support.
- Android home-screen widget with small, medium, and large responsive layouts.
- Integration with the existing Home, Prayer screen, Settings, Cubit, Clean Architecture, DI, storage, and routing.
- Full accuracy and scheduling test coverage.

---

## 2. CRITICAL RULE — INSPECT THE EXISTING PROJECT FIRST

Before writing or modifying code, inspect the entire existing project structure and understand how Siraty currently works.

Do not redesign the application.

The existing UI is the source of truth.

Inspect at minimum:

- Existing Prayer screen.
- Existing Home screen.
- Existing prayer cards.
- Existing upcoming-prayer card.
- Existing location display.
- Existing Settings screen.
- Existing navigation.
- Existing GoRouter configuration.
- Existing Cubit/Bloc conventions.
- Existing Feature-First structure.
- Existing Clean Architecture layers.
- Existing GetIt dependency injection.
- Existing local storage.
- Existing theme and Material 3 configuration.
- Existing colors.
- Existing typography.
- Existing spacing/radius conventions.
- Existing RTL behavior.
- Existing assets.
- Existing audio assets, if any.
- Existing notification/background packages.
- Existing Android configuration.
- Existing Gradle/Kotlin versions.
- Existing widget implementation, if any.

Follow this rule throughout implementation:

**«Inspect first → reuse first → implement second.»**

Do not create duplicate screens or duplicate architecture when an existing implementation can be extended.

---

## 3. Existing UI Must Remain Intact

The current prayer UI already contains the visual language that should be used.

The current application has:

- Prayer section in bottom navigation.
- Location near the top of the Prayer screen.
- Today's prayer list.
- Prayer time for each prayer.
- Circular/status indicators.
- A large upcoming-prayer card.
- Upcoming prayer time/countdown.
- Prayer information on Home.

Connect the existing UI to the new real prayer-time/domain system.

Do NOT:

- Create a second Prayer screen.
- Replace the existing prayer cards.
- Redesign the Home screen.
- Introduce a new visual system.
- Replace the existing theme.
- Rebuild Settings from scratch.
- Change unrelated navigation.
- Create duplicate Cubits.
- Create duplicate repositories.
- Introduce unrelated dependencies.

Only add UI that is genuinely missing.

---

## 4. Prayer Times

The system must support:

1. Fajr
2. Sunrise
3. Dhuhr
4. Asr
5. Maghrib
6. Isha

**Important:** Sunrise is not a prayer.

It is displayed as a daily astronomical time but must NOT have:

- Adhan.
- Prayer notification.
- Prayer reminder.
- Prayer status as a prayer.

Only these five prayer events receive notifications/Adhan:

- Fajr
- Dhuhr
- Asr
- Maghrib
- Isha

---

## 5. Prayer Calculation Engine

Use:

`adhan_dart "^2.0.1"`

Use the existing latest compatible package version if the repository's dependency constraints require a compatible adjustment, but do not replace the calculation engine with an online API.

The calculation must happen locally/offline.

The library provides astronomical calculations and supports calculation presets including the Egyptian General Authority of Survey method.

---

## 6. Egypt Calculation Configuration

For Egypt, use:

**Egyptian General Authority of Survey**

Parameters:

- Fajr: 19.5°
- Isha: 17.5°
- Asr: Shafi

Do NOT introduce arbitrary offsets.

Do NOT modify prayer times simply to force them to match a single reference.

Do NOT add user-editable offsets in V1.

The goal is to implement the standard calculation correctly and investigate genuine discrepancies through:

- Coordinates.
- Timezone.
- DST.
- Calculation method.
- Asr madhab.
- Date.
- Rounding.
- Astronomical precision.
- Reference-data methodology.

The default behavior should be:

**«Standard Egyptian calculation with zero manual adjustment.»**

---

## 7. Accuracy Validation

Prayer-time accuracy is a critical requirement.

Use the Egyptian General Authority of Survey as one of the trusted references for Egypt.

The official authority provides prayer-time calculations through its prayer-time service.

Validation should cover multiple Egyptian cities, for example:

- Cairo
- Giza
- Beni Suef
- Alexandria
- Aswan

And multiple dates covering different seasons.

At minimum validate:

- Fajr
- Sunrise
- Dhuhr
- Asr
- Maghrib
- Isha

Do not only validate one day.

Test dates should include:

- Winter.
- Spring.
- Summer.
- Autumn.
- Dates around daylight-saving/timezone transitions where applicable.
- Dates close to the beginning/end of the year.

Any discrepancy must be investigated rather than hidden with arbitrary offsets.

Document:

- Coordinates used.
- Calculation method.
- Madhab.
- Timezone.
- Date.
- Expected result.
- Calculated result.
- Difference.
- Reason for any remaining difference.

---

## 8. Location

### First Launch

On first launch, request location permission because prayer times depend on the user's location.

If permission is granted:

1. Get device location.
2. Resolve the location into a human-readable city/location.
3. Determine the location timezone.
4. Save the selected location.
5. Calculate prayer times.
6. Persist the prayer snapshot.
7. Update existing UI.
8. Update the Android widget.
9. Schedule prayer notifications and Adhan.

If location permission is denied:

- Do not break the application.
- Show the existing/appropriate location-selection UI.
- Allow manual city selection.
- Prayer functionality must remain usable.

---

## 9. Manual Location Change

The user must be able to change location later.

This is important because the user may move to another city.

Do NOT ask the user to enter latitude/longitude manually.

Instead:

**«Search for a city → select city → use its coordinates/timezone.»**

The selected location should contain enough information to calculate prayer times accurately, such as:

- City name.
- Country.
- Latitude.
- Longitude.
- Timezone.

The exact model should follow existing project conventions.

---

## 10. No Continuous GPS Tracking

V1 does NOT require continuous background GPS tracking.

Do not:

- Continuously monitor GPS.
- Wake the application continuously to detect movement.
- Recalculate prayer times every few minutes based on GPS.

Location changes are explicit:

- First launch automatic detection.
- Manual city selection later.

Optionally, if the existing architecture already supports a safe one-time refresh, it may be reused, but continuous tracking is not part of V1.

---

## 11. Offline Requirement

Prayer calculation must work without internet.

Do not depend on a prayer-times API for the core prayer calculation.

The application should be able to calculate:

- Today's prayer times.
- Tomorrow's prayer times.

while completely offline.

Internet must not be required for normal prayer calculations.

---

## 12. Single Source of Truth

There must be one prayer-time domain/repository system used by:

- Home.
- Prayer screen.
- Settings where relevant.
- Notifications.
- Adhan scheduler.
- Android widget.

The widget must NOT independently calculate prayer times.

The Android native layer must NOT contain a second astronomy implementation.

The architecture should be:

```
Location
   ↓
Prayer Repository
   ↓
Prayer Calculation
   ↓
Prayer Domain Model
   ↓
Persistence / Cached Snapshot
   ↓
 ┌───────────────┬──────────────┬──────────────┐
 ↓               ↓              ↓
Home          Prayer Screen   Scheduler
                                  ↓
                               Widget
```

---

## 13. Prayer Status

Every prayer should have a derived status:

- PASSED
- CURRENT
- UPCOMING

The status must be derived from the current time and today's prayer times.

Do not persist status as the source of truth.

Example:

```
Fajr       PASSED
Sunrise    PASSED
Dhuhr      CURRENT
Asr        UPCOMING
Maghrib    UPCOMING
Isha       UPCOMING
```

The exact visual representation must reuse the existing UI.

---

## 14. Next Prayer

The next prayer must be derived from the current date/time.

Rules:

**Before Fajr** — Next prayer: Fajr

**Between Fajr and Isha** — Next prayer: next upcoming prayer today

**After Isha** — Next prayer: tomorrow's Fajr

Do not incorrectly show yesterday/today values around midnight.

---

## 15. Countdown

The countdown must be calculated as:

`nextPrayerTime - currentTime`

Do NOT:

- Recalculate astronomical prayer times every second.
- Persist a countdown value.
- Run unnecessary background processes every second.

The UI can update the countdown while the screen is active using normal Flutter UI mechanisms.

For the widget, use platform-appropriate update behavior and avoid waking the application every minute solely for a countdown.

---

## 16. Settings

Extend the existing Settings screen.

Do not rebuild it.

Add a prayer/Adhan settings section using the existing design language.

Settings should include:

**Prayer Notifications / Adhan** — Enable / disable.

**Location** — Show current selected city. Allow changing the city.

**Adhan Reciter** — Allow selecting an available reciter.

Only display reciters for which valid licensed/local audio assets actually exist.

Do not invent reciter names or asset paths.

---

## 17. Reminder Timing

Each prayer receives a reminder:

**10 minutes before prayer time.**

This is fixed in V1.

Do not add a user-configurable reminder duration.

For each prayer:

`Prayer time - 10 minutes`

Example:

```
Dhuhr: 12:15
Reminder: 12:05
Adhan: 12:15
```

Sunrise receives neither.

---

## 18. Notifications

For each prayer:

**Reminder event** — At: `PrayerTime - 10 minutes`. Show a notification.

**Adhan event** — At: `PrayerTime`. Trigger the Adhan.

Both must work when:

- App is foreground.
- App is background.
- Screen is locked.
- App process is not actively running.
- Device has been rebooted, after schedules are restored.

---

## 19. Android Scheduling

Do NOT use:

- `Timer.periodic`
- `Future.delayed`
- Flutter polling
- A background loop that wakes every minute
- Continuous Dart execution

for reliable prayer event scheduling.

Use Android's alarm infrastructure.

Preferred approach: **Android AlarmManager exact alarms**, because prayer events are time-sensitive user-facing events.

The native Android layer should schedule exact events.

The implementation must account for Android exact-alarm permission behavior.

Use `SCHEDULE_EXACT_ALARM` where appropriate for the supported Android target/policy configuration.

Do not blindly add `USE_EXACT_ALARM` without verifying that the application's target SDK and Google Play policy allow and justify it.

Before scheduling: `canScheduleExactAlarms()` must be checked.

If exact alarms are unavailable:

- Do not crash.
- Do not pretend the event is exact.
- Provide an appropriate path/instruction for the user to enable the required system access when appropriate.
- Keep prayer UI/widget functionality working.
- Document the limitation.

---

## 20. Android Notification Permission

Android 13+ requires notification permission.

Handle `POST_NOTIFICATIONS` appropriately.

Notification permission denial must NOT break:

- Prayer calculations.
- Prayer screen.
- Home.
- Location.
- Widget.

The app should request notification permission contextually, following Android best practices.

---

## 21. Full-Screen Intent

Do not rely on unrestricted full-screen notifications as an Adhan workaround.

Android 14+ has restrictions around full-screen intents.

Use normal notification/audio behavior appropriate for the application and document any platform limitations.

If a full-screen experience is considered later, it must comply with the current Android and Google Play policy.

---

## 22. Adhan Audio

Adhan audio must work offline.

Audio files must be bundled with the application.

Do NOT download Adhan audio at runtime.

The project must contain only properly licensed/authorized audio assets.

Each reciter should have a deterministic asset mapping.

Example conceptual model:

```
Reciter
 ├── id
 ├── displayName
 └── assetPath
```

The exact model should follow existing project conventions.

If a reciter's audio files are not actually available: do not expose that reciter in the UI.

---

## 23. Reciter Selection

When the user changes the reciter:

1. Persist the selected reciter.
2. Keep current prayer times unchanged.
3. Cancel/rebuild only the future Adhan scheduling as necessary.
4. Do not duplicate alarms.
5. Ensure future Adhan events use the newly selected reciter.

Do not require internet.

---

## 24. Alarm Scheduling Strategy

Use deterministic scheduling.

Recommended strategy:

- Cancel existing Siraty prayer alarms.
- Calculate today's prayer times.
- Calculate tomorrow's prayer times.
- Schedule remaining events.
- Schedule tomorrow's events.
- Rebuild at the appropriate day boundary.

For each prayer create two possible events:

- REMINDER
- ADHAN

Sunrise gets neither.

Alarm IDs must be deterministic.

For example, conceptually: `date + prayer + eventType`

Do not use random IDs.

This allows reliable:

- Cancellation.
- Rescheduling.
- Recovery.
- Duplicate prevention.

---

## 25. When Schedules Must Be Rebuilt

Rebuild prayer schedules when:

1. Location changes.
2. New day starts.
3. Device reboots.
4. Device timezone changes.
5. Relevant exact-alarm permission changes.
6. Prayer notifications are enabled/disabled.
7. Selected reciter changes, if needed for future Adhan alarms.
8. App installation/update recovery requires it.
9. Cached schedule is missing or invalid.

---

## 26. Device Reboot

Android alarms may be cleared during reboot.

Implement a native Android boot receiver: `BOOT_COMPLETED`

After reboot:

1. Load persisted location/settings.
2. Recalculate current/future prayer times.
3. Rebuild prayer alarms.
4. Update widget state.

Do not require the user to manually open Siraty after every reboot.

---

## 27. Timezone

Do not assume: `device timezone == selected location timezone`

The selected location must carry timezone information.

Prayer calculations must use the selected location's correct timezone.

If the device timezone changes:

1. Detect the change.
2. Recalculate prayer times.
3. Update UI.
4. Update widget.
5. Reschedule future alarms.

The implementation must avoid silently scheduling an Egypt prayer time using an unrelated device timezone.

---

## 28. Architecture

Follow the existing:

- Feature-First
- Clean Architecture
- Cubit/Bloc
- GetIt
- GoRouter

Do not introduce a different architecture.

Conceptually:

```
features/
└── prayer/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │
    └── presentation/
        ├── cubit/
        ├── pages/
        └── widgets/
```

The actual directory names must match the existing repository.

---

## 29. Suggested Domain Responsibilities

Adapt these to existing naming conventions.

Potential entities:

- PrayerTime
- PrayerDay
- PrayerLocation
- PrayerEvent
- AdhanReciter

Potential use cases:

- GetPrayerTimes
- GetNextPrayer
- GetPrayerStatus
- GetSavedLocation
- SetPrayerLocation
- SetPrayerNotificationsEnabled
- SetAdhanReciter
- RefreshPrayerSchedule
- SchedulePrayerEvents
- CancelPrayerEvents

Do not create unnecessary use cases if the current project follows a different but clean convention.

---

## 30. Android Boundary

Android-specific functionality must be isolated.

Flutter/domain code should not directly depend on:

- AlarmManager.
- BroadcastReceiver.
- Android notification APIs.
- Android widget APIs.
- Android audio APIs.

Use an abstraction/interface between Flutter and Android-specific implementation.

Conceptually:

```
Prayer Scheduler Interface
        ↓
Android Prayer Scheduler
        ↓
AlarmManager
```

Similarly:

```
Widget Update Interface
        ↓
Android Widget Implementation
```

This keeps the domain layer platform-independent and testable.

---

## 31. Dependency Injection

Register all new services through the existing GetIt setup.

Potential services:

- PrayerCalculationDataSource
- PrayerLocalDataSource
- PrayerRepository
- PrayerScheduler
- PrayerWidgetService
- LocationService

Only add services that are actually required.

Follow the project's current registration pattern.

---

## 32. Persistence

Use the existing local-storage solution already used by Siraty.

Do NOT introduce a new database just for this feature.

Persist at minimum:

- Selected location
- Latitude
- Longitude
- Timezone
- Selected city/country
- Notifications enabled
- Selected Adhan reciter
- Cached prayer snapshot

Potential scheduler metadata may also be persisted if required.

The exact storage model should follow existing conventions.

---

## 33. Location Change Flow

The complete flow must be:

```
User selects new city
        ↓
Save location
        ↓
Calculate prayer times
        ↓
Persist prayer snapshot
        ↓
Update Cubit/state
        ↓
Existing Home UI refreshes
        ↓
Existing Prayer UI refreshes
        ↓
Update widget
        ↓
Cancel old alarms
        ↓
Schedule new alarms
```

This flow must be deterministic.

---

## 34. Home Integration

The Home screen already contains prayer information.

Do not redesign it.

Connect it to the same Prayer Repository/Cubit/domain data.

The existing:

- prayer cards,
- prayer times,
- status indicators,
- upcoming-prayer card,
- countdown,

must reflect the actual calculated prayer data.

There must not be one calculation for Home and another for the Prayer screen.

---

## 35. Prayer Screen Integration

Use the existing Prayer screen.

Connect:

- Location.
- Today's date.
- Prayer times.
- Prayer status.
- Next prayer.
- Countdown.

Keep the existing visual hierarchy.

Only add missing functionality such as location selection controls if they do not already exist.

---

## 36. Android Widget

Implement an Android home-screen widget.

V1 supports:

- Small.
- Medium.
- Large.

The widget must be responsive.

If the project already contains a widget implementation, extend it rather than replacing it.

If there is no existing implementation, native Android Jetpack Glance is an acceptable approach.

Use a Glance version compatible with the existing Android/Gradle/Kotlin configuration.

Do not blindly upgrade the whole Android toolchain only to add the widget.

---

## 37. Widget — Small

Small widget should focus on essential information:

- Next Prayer
- Prayer Time
- Countdown

Example conceptual layout:

```
العصر
04:18 م
متبقي 01:23
```

Reuse Siraty's visual identity.

---

## 38. Widget — Medium

Medium widget should show:

- Next prayer.
- Prayer time.
- Countdown.
- Several upcoming prayers.

Example conceptual information:

```
العصر
04:18 م
متبقي 01:23

المغرب   06:42 م
العشاء   08:05 م
```

The exact UI should follow the app's existing design language.

---

## 39. Widget — Large

Large widget should show:

- Location.
- Next prayer.
- Countdown.
- Today's prayer list.
- Prayer status.

Example conceptual structure:

```
بني سويف

الصلاة القادمة
العصر
04:18 م
متبقي 01:23

الفجر      04:xx
الشروق     06:xx
الظهر      12:xx
العصر      04:18
المغرب     06:42
العشاء     08:05
```

Again, this is conceptual content, not a request to copy this visual layout exactly.

Use the existing Siraty design system.

---

## 40. Widget Data

The widget must use the same persisted prayer snapshot as the Flutter application.

Do NOT implement: Widget → independently calculate astronomy

Instead:

```
Flutter Prayer System
        ↓
Persisted Shared Prayer Snapshot
        ↓
Android Widget
```

The widget should have access to enough data to render even when the Flutter application process is not running.

---

## 41. Widget State

Android widgets run independently of the Flutter UI process.

Therefore:

- Persist required widget data.
- Update the widget after prayer data changes.
- Update it after location changes.
- Update it after the new day.
- Update it after relevant settings changes.

Do not rely on an in-memory Flutter Cubit for widget persistence.

---

## 42. Widget Updates

Do not update the widget every minute simply to redraw a countdown.

Avoid: wake app every minute.

Use Android/Glance-supported update mechanisms and practical update intervals.

The exact implementation should balance:

- Correctness.
- Battery.
- Android widget limitations.

When the user opens Siraty, the application can refresh the relevant state.

When prayer boundaries occur, update the widget accordingly.

---

## 43. Widget Interactions

If practical and consistent with the current application:

- Tapping the widget should open Siraty.
- Prefer opening the existing Prayer screen rather than creating a new screen.

Do not introduce a second prayer UI specifically for widgets.

---

## 44. RTL

Siraty is RTL-first.

The entire feature must support Arabic RTL correctly.

Verify:

- Prayer names.
- Times.
- Countdown.
- Location.
- Widget.
- Settings.
- Notifications.

Do not hardcode LTR layouts.

---

## 45. Localization

Reuse the existing localization system.

Do not hardcode user-facing strings if Siraty already has localization infrastructure.

Prayer names should come from the existing localization conventions.

---

## 46. Error Handling

The feature must gracefully handle:

**Location permission denied** — Allow manual location selection.

**Location unavailable** — Do not crash. Use the last saved location if available.

**No saved location** — Show appropriate location-selection UI.

**Exact alarm permission denied** — Do not crash. Keep prayer calculations/UI/widget working and clearly handle the scheduling limitation.

**Notification permission denied** — Keep all prayer functionality except notifications.

**Missing audio asset** — Do not schedule a broken Adhan. Log/report the issue appropriately.

**Corrupt/missing cached prayer data** — Recalculate locally.

**Timezone change** — Recalculate and reschedule.

**Device reboot** — Restore schedule.

---

## 47. Performance Requirements

Avoid:

- Continuous GPS.
- Prayer API polling.
- Astronomical calculations every second.
- Background loops.
- One-minute Dart timers for scheduling.
- Duplicate repositories.
- Duplicate prayer calculations.
- Excessive widget updates.

Prayer calculations should occur only when necessary:

- Location changes.
- New day.
- Timezone changes.
- Schedule rebuild.
- Cache invalidation.

---

## 48. Testing — Calculation

Create unit tests covering:

**Calculation parameters** — Verify: Egyptian method, Fajr 19.5°, Isha 17.5°, Shafi Asr, 0 offsets

**Prayer ordering** — Verify: Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha

**Known coordinates** — Test multiple Egyptian cities.

**Multiple dates** — Test multiple seasons.

**Timezone** — Verify selected location timezone is used correctly.

---

## 49. Testing — Prayer State

Test:

**Before Fajr** — Next prayer = Fajr.

**Between prayers** — Next prayer = next upcoming prayer.

**During prayer time** — Current prayer is identified correctly.

**After Isha** — Next prayer = next day's Fajr.

**Around midnight** — Ensure date transition is correct.

**Sunrise** — Ensure Sunrise never receives prayer status behavior intended for one of the five prayers.

---

## 50. Testing — Repository

Test:

- Save location.
- Load location.
- Update location.
- Save notification setting.
- Load notification setting.
- Save reciter.
- Load reciter.
- Save prayer snapshot.
- Load prayer snapshot.
- Replace stale snapshot.

---

## 51. Testing — Scheduler

Test:

**Reminder** — For every prayer: `event = prayerTime - 10 minutes`

**Adhan** — `event = prayerTime`

**Sunrise** — No event.

**Cancellation** — Old alarms are removed.

**Rescheduling** — New alarms replace old ones.

**Deterministic IDs** — Same prayer/date/event produces same alarm ID.

**Duplicate prevention** — Calling schedule multiple times does not create duplicate events.

**Location change** — Old location alarms are cancelled and new ones scheduled.

---

## 52. Android Manual Testing

Manually test on real Android devices where possible.

Test:

- App foreground.
- App background.
- Screen locked.
- App process terminated.
- Doze mode.
- Battery optimization scenarios.
- Notification permission denied.
- Exact alarm permission available.
- Exact alarm permission denied.
- Device reboot.
- Timezone change.
- Location change.
- Reciter change.
- Notification enabled/disabled.
- Widget added.
- Widget resized.
- Offline mode.

---

## 53. Accuracy Validation Matrix

Create a validation matrix such as:

| City | Coordinates | Date | Fajr | Sunrise | Dhuhr | Asr | Maghrib | Isha |
|---|---|---|---|---|---|---|---|---|
| Cairo | Reference | Winter | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Giza | Reference | Spring | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Beni Suef | Reference | Summer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Alexandria | Reference | Autumn | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Aswan | Reference | Multiple | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

The actual test data should be generated and documented during implementation.

---

## 54. No Arbitrary Prayer-Time Offsets

This is explicitly prohibited in V1.

Do not do:

```
Fajr + 2 minutes
Asr - 1 minute
Isha + 3 minutes
```

just because one reference differs.

If a discrepancy exists, determine the actual cause first.

Potential causes:

- Coordinates.
- Calculation convention.
- Timezone.
- DST.
- Rounding.
- Reference source methodology.
- High-latitude rules where applicable.
- Asr madhab.

---

## 55. Dependencies

Before adding dependencies:

1. Inspect `pubspec.yaml`.
2. Check whether an existing dependency already solves the requirement.
3. Reuse existing packages where possible.
4. Add only necessary packages.
5. Check compatibility with current Flutter/Dart version.
6. Check Android Gradle/Kotlin compatibility.

Required calculation package:

`adhan_dart: ^2.0.1`

Only add location/search/audio/widget packages when actually needed and compatible with the current project.

Do not add redundant packages.

---

## 56. Android Native Implementation

Inspect `android/` before making changes.

Understand:

- compileSdk.
- targetSdk.
- minSdk.
- Gradle version.
- Kotlin version.
- AndroidManifest.
- Existing MainActivity.
- Existing receivers/services.
- Existing dependencies.

Then implement only what is necessary.

Potential native components:

- AlarmManager scheduling
- BroadcastReceiver for prayer alarms
- BOOT_COMPLETED receiver
- Notification handling
- Adhan audio playback
- Widget receiver
- Glance widget

Do not create components that are not required.

---

## 57. Scheduling Event Model

Conceptually:

```
PrayerEvent
├── prayer
├── eventType
├── date
├── scheduledAt
└── alarmId
```

Where `eventType`: reminder, adhan

Sunrise is excluded.

---

## 58. Scheduler Lifecycle

Recommended lifecycle:

```
App startup
    ↓
Load saved settings/location
    ↓
Calculate today's prayer times
    ↓
Calculate tomorrow's prayer times
    ↓
Update repository/cache
    ↓
Schedule remaining events
    ↓
Update widget
```

When the day changes:

```
New day
   ↓
Recalculate
   ↓
Replace snapshot
   ↓
Reschedule
   ↓
Update widget
```

---

## 59. Location Lifecycle

First launch:

```
Request permission
   ↓
Get location
   ↓
Resolve city/timezone
   ↓
Save location
   ↓
Calculate prayers
   ↓
Update UI
   ↓
Update widget
   ↓
Schedule events
```

Manual:

```
Search city
   ↓
Select city
   ↓
Save
   ↓
Recalculate
   ↓
Update UI
   ↓
Update widget
   ↓
Cancel old alarms
   ↓
Schedule new alarms
```

---

## 60. Settings Lifecycle

**Notification disabled:**

```
Save disabled
↓
Cancel prayer notification/Adhan alarms
↓
Keep prayer calculations
↓
Keep widget
```

**Notification enabled:**

```
Save enabled
↓
Check exact alarm permission
↓
Schedule future events
```

**Reciter changed:**

```
Save reciter
↓
Ensure future Adhan events use new reciter
```

---

## 61. Widget Lifecycle

When prayer data changes:

```
Prayer Repository
       ↓
Persist snapshot
       ↓
Widget update
```

When location changes:

```
Location changed
       ↓
Recalculate
       ↓
Persist
       ↓
Widget update
```

When a new day begins:

```
New day
   ↓
Recalculate
   ↓
Persist
   ↓
Widget update
```

---

## 62. UI Implementation Rules

The UI must use:

- Existing theme.
- Existing colors.
- Existing typography.
- Existing spacing.
- Existing border radius.
- Existing components.
- Existing icons where appropriate.
- Existing animations where appropriate.

Do not introduce arbitrary:

- Colors.
- Fonts.
- Shadows.
- Card styles.
- Gradients.
- Button styles.

If an existing component can be reused, reuse it.

---

## 63. Code Quality

Implementation must be production quality.

Follow:

- Existing naming conventions.
- Existing lint rules.
- SOLID principles.
- Clean Architecture boundaries.
- Dependency inversion.
- Small focused classes.
- Testable abstractions.
- Proper error handling.
- No duplicated business logic.

Do not place prayer calculation logic directly inside widgets/pages.

Do not place scheduling logic directly inside Cubits.

---

## 64. Required Final Verification

After implementation, run:

```
flutter analyze
flutter test
```

and any Android-specific build/test commands appropriate for the project.

Verify there are no new analyzer errors.

Verify the Android app builds successfully.

Verify the widget builds successfully.

Verify all newly added native Android code compiles.

---

## 65. Final Implementation Report

After completing the implementation, provide a concise implementation report containing exactly these sections:

1. **Files Changed** — List every important file added/modified.
2. **Dependencies** — List every dependency added/updated and explain why.
3. **Android Permissions** — List all Android permissions added and why.
4. **Native Android Components** — List: Receivers, AlarmManager implementation, Notification implementation, Audio implementation, Widget implementation, Boot handling.
5. **Prayer Calculation** — State: Calculation library, Calculation method, Fajr angle, Isha angle, Asr madhab, Offsets.
6. **Accuracy Validation** — Explain: Cities tested, Dates tested, Reference data, Results, Any discrepancies and their causes.
7. **Alarm Scheduling** — Explain: Reminder timing, Adhan timing, Exact alarm handling, Deterministic IDs, Cancellation, Rescheduling, Reboot recovery.
8. **Widget** — Explain: Small, Medium, Large, Data-sharing mechanism, Update strategy.
9. **Tests** — List tests added and their results.
10. **Platform Limitations** — Clearly document any Android/Google Play limitations related to: Exact alarms, Notification permission, Background execution, Audio, Full-screen intents, Widget updates.

---

## 66. Important Implementation Principle

The final result should feel like a natural extension of Siraty.

It must NOT feel like a separate prayer application embedded inside Siraty.

The existing Siraty design and architecture are the foundation.

The goal is:

```
Existing Siraty UI
        +
Accurate Prayer Domain
        +
Offline Calculation
        +
Reliable Android Scheduling
        +
Offline Adhan
        +
Responsive Widget
        =
Complete Siraty Prayer System
```

---

## 67. Sources / Technical References

Use these sources as implementation references and verify the current platform/package behavior during implementation:

1. Adhan Dart — pub.dev: https://pub.dev/packages/adhan_dart
2. Android — Schedule exact alarms: https://developer.android.com/develop/background-work/services/alarms
3. Android — Exact alarm permission behavior: https://developer.android.com/about/versions/14/changes/schedule-exact-alarms
4. Android — Alarm permission documentation: https://developer.android.com/reference/android/Manifest.permission#SCHEDULE_EXACT_ALARM
5. Android — Notification runtime permission: https://developer.android.com/develop/ui/views/notifications/notification-permission
6. Android Jetpack Glance App Widgets: https://developer.android.com/develop/ui/compose/glance/glance-app-widget
7. Egyptian General Authority of Survey — Prayer Times: https://www.esa.gov.eg/praytimes.aspx
8. Egyptian General Authority of Survey — Monthly Prayer Times: https://www.esa.gov.eg/monthlypraytimes.aspx
