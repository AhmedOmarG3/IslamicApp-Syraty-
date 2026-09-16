import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_day.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_location.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_time.dart';

void main() {
  group('Prayer Status and Next/Current Prayer Derivation Tests', () {
    const location = PrayerLocation.defaultLocation;
    final baseDate = DateTime(2026, 9, 7);

    final fajrTime = DateTime(2026, 9, 7, 5, 5);
    final sunriseTime = DateTime(2026, 9, 7, 6, 35);
    final dhuhrTime = DateTime(2026, 9, 7, 12, 54);
    final asrTime = DateTime(2026, 9, 7, 16, 25);
    final maghribTime = DateTime(2026, 9, 7, 19, 11);
    final ishaTime = DateTime(2026, 9, 7, 20, 29);

    final prayerDay = PrayerDay(
      date: baseDate,
      location: location,
      times: [
        PrayerTime(key: PrayerType.fajr, time: fajrTime),
        PrayerTime(key: PrayerType.sunrise, time: sunriseTime),
        PrayerTime(key: PrayerType.dhuhr, time: dhuhrTime),
        PrayerTime(key: PrayerType.asr, time: asrTime),
        PrayerTime(key: PrayerType.maghrib, time: maghribTime),
        PrayerTime(key: PrayerType.isha, time: ishaTime),
      ],
    );

    test('Before Fajr (e.g. 04:00): next prayer is Fajr, current prayer is null', () {
      final now = DateTime(2026, 9, 7, 4, 0);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.nextPrayer(now)?.key, PrayerType.fajr);
      expect(derived.currentPrayer(now), isNull);
      for (final t in derived.times) {
        expect(t.status, PrayerStatus.upcoming);
      }
    });

    test('During Fajr active window (05:20): Fajr is current, next prayer is Dhuhr (sunrise excluded)', () {
      final now = DateTime(2026, 9, 7, 5, 20);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now)?.key, PrayerType.fajr);
      expect(derived.nextPrayer(now, includeSunrise: false)?.key, PrayerType.dhuhr);
      expect(derived.getTime(PrayerType.fajr)?.status, PrayerStatus.current);
      expect(derived.getTime(PrayerType.sunrise)?.status, PrayerStatus.upcoming);
      expect(derived.getTime(PrayerType.dhuhr)?.status, PrayerStatus.upcoming);
    });

    test('Between Sunrise and Dhuhr (e.g. 09:00): Fajr & Sunrise passed, Dhuhr is next', () {
      final now = DateTime(2026, 9, 7, 9, 0);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now), isNull);
      expect(derived.nextPrayer(now)?.key, PrayerType.dhuhr);
      expect(derived.getTime(PrayerType.fajr)?.status, PrayerStatus.passed);
      expect(derived.getTime(PrayerType.sunrise)?.status, PrayerStatus.passed);
      expect(derived.getTime(PrayerType.dhuhr)?.status, PrayerStatus.upcoming);
    });

    test('During Dhuhr active window (13:10): Dhuhr is current, Asr is next', () {
      final now = DateTime(2026, 9, 7, 13, 10);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now)?.key, PrayerType.dhuhr);
      expect(derived.nextPrayer(now)?.key, PrayerType.asr);
      expect(derived.getTime(PrayerType.dhuhr)?.status, PrayerStatus.current);
      expect(derived.getTime(PrayerType.asr)?.status, PrayerStatus.upcoming);
    });

    test('After Dhuhr active window (14:00): Dhuhr transitions to passed (completed), Asr is next', () {
      final now = DateTime(2026, 9, 7, 14, 0);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now), isNull);
      expect(derived.nextPrayer(now)?.key, PrayerType.asr);
      expect(derived.getTime(PrayerType.dhuhr)?.status, PrayerStatus.passed);
      expect(derived.getTime(PrayerType.asr)?.status, PrayerStatus.upcoming);
    });

    test('During Isha window (20:45): Isha is current, nextPrayer is null', () {
      final now = DateTime(2026, 9, 7, 20, 45);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now)?.key, PrayerType.isha);
      expect(derived.nextPrayer(now), isNull);
      expect(derived.getTime(PrayerType.fajr)?.status, PrayerStatus.passed);
      expect(derived.getTime(PrayerType.maghrib)?.status, PrayerStatus.passed);
      expect(derived.getTime(PrayerType.isha)?.status, PrayerStatus.current);
    });

    test('After Isha window (e.g. 21:30): Isha transitions to passed, all 5 prayers passed', () {
      final now = DateTime(2026, 9, 7, 21, 30);
      final derived = prayerDay.withDerivedStatuses(now);

      expect(derived.currentPrayer(now), isNull);
      expect(derived.nextPrayer(now), isNull);
      expect(derived.getTime(PrayerType.isha)?.status, PrayerStatus.passed);
    });
  });
}
