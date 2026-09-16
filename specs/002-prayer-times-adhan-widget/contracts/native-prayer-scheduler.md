# Contract: Native Prayer Scheduler (Dart ↔ Android MethodChannel)

**Channel**: `siraty/prayer_scheduler`
**Dart side**: `lib/core/services/prayer_scheduler_interface.dart`
(abstract interface; Android implementation via MethodChannel).
**Android side**: `PrayerSchedulerPlugin.kt` + receivers.

The domain layer depends only on the Dart interface — never on
AlarmManager, receivers, notifications, widgets, or audio APIs.

## Methods (Dart → Android)

### `scheduleEvents(List<PrayerEventPayload>)`

- **Payload per event**: `alarmId` (int, deterministic), `epochMillis`
  (int), `prayerKey` (string), `eventType` ("reminder" | "adhan"),
  `reciterAsset` (string, adhan only), `title`/`body` (Arabic strings).
- **Behavior**: cancels any existing Siraty prayer alarms not present in
  the payload (or all, if caller passes `cancelAll: true` first), then
  registers each event as an exact alarm
  (`setExactAndAllowWhileIdle`) if `canScheduleExactAlarms()` — otherwise
  inexact with the same IDs. Returns
  `{exact: bool}` so Dart can surface degraded precision.
- **Errors**: returns typed error codes (`PERMISSION_DENIED`,
  `SCHEDULING_FAILED`); never crashes.

### `cancelAllPrayerEvents()`

- Cancels every alarm whose ID belongs to the Siraty prayer ID space
  (deterministic range). Idempotent.

### `updateWidget(WidgetSnapshotPayload)`

- **Payload**: next prayer, countdown target, today's times+statuses,
  location name — the same snapshot data.
- **Behavior**: refreshes small/medium/large widgets from shared storage.

### `canScheduleExactAlarms()` → bool

### `requestExactAlarmPermission()` → bool

- Opens system settings if permitted; returns whether access was granted.

### `requestNotificationPermission()` → bool

- Requests `POST_NOTIFICATIONS` (API 33+) contextually; returns whether
  granted. All notifications are posted by the native layer — there is no
  Dart notification mechanism (single notification stack).

## Broadcasts handled (Android → internal)

| Receiver | Action | Response |
|---|---|---|
| `PrayerAlarmReceiver` | alarm fire | REMINDER → silent notification (tap → Prayer screen deep link); ADHAN → notification + `MediaPlayer` playback of bundled reciter asset |
| `PrayerBootReceiver` | `BOOT_COMPLETED`, `TIMEZONE_CHANGED`, `MY_PACKAGE_REPLACED` | read persisted snapshot from shared storage, reschedule remaining events, update widget — without launching the Flutter UI |

## Notification channels

| Channel | Purpose |
|---|---|
| `siraty_prayer_reminders` | silent reminder notifications |
| `siraty_adhan` | adhan notifications |

## Deep link

All notification/widget taps route to the existing GoRouter Prayer
screen path — no new screens.

## Permissions (AndroidManifest)

`SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`,
`ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` — each with the runtime
denial behavior defined in spec FR-010.
