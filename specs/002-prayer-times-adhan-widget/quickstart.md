# Quickstart: Validate the Prayer Times Feature End-to-End

**Date**: 2026-09-07 | **Plan**: [plan.md](plan.md)

Prerequisites: Flutter stable (Dart ^3.5.3), a real Android device (or
emulator with exact-alarm support), licensed Adhan audio assets in
`assets/audio/adhan/`, `assets/json/cities.json` present.

## Automated validation

```powershell
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze          # must report no new issues
flutter test             # all prayer tests must pass
```

Key suites (see [data-model.md](data-model.md) for rules):

1. **Calculation**: Egyptian parameters (19.5°/17.5°/Shafi); time ordering
   fajr < sunrise < … < isha; known cities × seasonal dates against the
   validation matrix; location timezone honored (not device timezone).
2. **State**: before-fajr / between / current / after-Isha → tomorrow's
   fajr; midnight date transition; sunrise excluded from prayer status.
3. **Repository**: save/load location, settings, reciter, snapshot;
   stale snapshot replacement.
4. **Scheduler** (with fake clock + fake platform channel): reminder =
   time − 10 min; adhan = time; sunrise no events; deterministic IDs;
   duplicate prevention; cancellation on location change/disable.

## Android build

```powershell
flutter build apk --debug   # native receivers + widget must compile
```

## Manual device matrix (spec Story 2/3)

For each state — foreground, background, locked, process killed, Doze,
reboot — verify with a prayer a few minutes ahead:

- [ ] Reminder notification appears exactly 10 minutes before (silent).
- [ ] Adhan plays at the exact prayer time with the selected reciter.
- [ ] Notification tap opens the existing Prayer screen.
- [ ] After reboot, alarms restore without opening the app.
- [ ] Timezone change recalculates and reschedules.
- [ ] Change city via one-tap location and via search → UI + widget + alarms update.
- [ ] Disable notifications → alarms stop; times/UI/widget keep working.
- [ ] Switch reciter → next Adhan uses it, no duplicates.
- [ ] Offline (airplane mode): calculation and city search still work.

## Widget checks

- [ ] Small / medium / large render correctly in RTL Arabic.
- [ ] Widget data matches app after: kill, reboot, city change, new day.
- [ ] Widget does not update every minute (check battery: no per-minute wake).
- [ ] Tap opens existing Prayer screen.

## Permission degradation

- [ ] Deny location → manual search works, no crash.
- [ ] Deny notifications → everything except notifications works.
- [ ] Deny exact alarms → graceful message, inexact fallback, UI intact.

Expected outcome: every check passes; discrepancies go to the accuracy
validation matrix, never to time offsets.
