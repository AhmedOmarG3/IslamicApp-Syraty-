# Quickstart Validation Guide

## Prerequisites

- Repository-compatible Flutter/Dart SDK
- Supported Android device/emulator including a narrow screen
- Clean and upgrade fixtures containing valid, missing, boundary, and invalid `last_read_index`
- Approved Quran and Azkar reference assets
- Controllable prayer success, timeout, offline, malformed, and stale scenarios

## Baseline commands

```powershell
dart format --output=none lib test
flutter analyze
flutter test
```

## Validation scenarios

1. Start the app and exercise all current core routes; malformed detail-route arguments recover safely.
2. Upgrade each Quran-progress fixture; valid data survives and invalid data is not destructively overwritten.
3. Disable networking; Quran and Azkar remain available from approved assets.
4. Exercise every prayer state plus date/timezone boundaries; verify provenance and honest Arabic messages.
5. Validate religious asset structure, relationships, fingerprints, and mutation detection.
6. Test Arabic RTL, 200% text scale, narrow screens, and 48x48 touch targets.
7. Review the diff to confirm no unrelated/user-owned changes or protected contracts changed.

Retain outcomes using [release-evidence.md](contracts/release-evidence.md).

