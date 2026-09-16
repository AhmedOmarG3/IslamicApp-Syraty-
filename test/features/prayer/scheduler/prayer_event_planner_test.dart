import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/prayer/data/models/prayer_snapshot_model.dart';
import 'package:siraty/features/prayer/domain/entities/adhan_reciter.dart';
import 'package:siraty/features/prayer/domain/entities/calculation_method_setting.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_day.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_location.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_time.dart';
import 'package:siraty/features/prayer/domain/services/prayer_event_planner.dart';

void main() {
  const planner = PrayerEventPlanner();

  group('T022: PrayerEventPlanner Scheduler Logic Tests', () {
    final baseDate = DateTime(2026, 9, 7);
    const location = PrayerLocation.defaultLocation;

    final todayPrayers = [
      PrayerTime(key: PrayerType.fajr, time: DateTime(2026, 9, 7, 5, 0)),
      PrayerTime(key: PrayerType.sunrise, time: DateTime(2026, 9, 7, 6, 30)),
      PrayerTime(key: PrayerType.dhuhr, time: DateTime(2026, 9, 7, 12, 0)),
      PrayerTime(key: PrayerType.asr, time: DateTime(2026, 9, 7, 15, 30)),
      PrayerTime(key: PrayerType.maghrib, time: DateTime(2026, 9, 7, 18, 0)),
      PrayerTime(key: PrayerType.isha, time: DateTime(2026, 9, 7, 19, 30)),
    ];

    final tomorrowPrayers = [
      PrayerTime(key: PrayerType.fajr, time: DateTime(2026, 9, 8, 5, 0)),
      PrayerTime(key: PrayerType.sunrise, time: DateTime(2026, 9, 8, 6, 30)),
      PrayerTime(key: PrayerType.dhuhr, time: DateTime(2026, 9, 8, 12, 0)),
      PrayerTime(key: PrayerType.asr, time: DateTime(2026, 9, 8, 15, 30)),
      PrayerTime(key: PrayerType.maghrib, time: DateTime(2026, 9, 8, 18, 0)),
      PrayerTime(key: PrayerType.isha, time: DateTime(2026, 9, 8, 19, 30)),
    ];

    final snapshot = PrayerSnapshotModel(
      today: PrayerDay(date: baseDate, location: location, times: todayPrayers),
      tomorrow: PrayerDay(date: baseDate.add(const Duration(days: 1)), location: location, times: tomorrowPrayers),
      location: location,
      method: const CalculationMethodSetting(),
      generatedAt: baseDate,
    );

    test('Sunrise is completely excluded from scheduled events', () {
      final now = DateTime(2026, 9, 7, 0, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      final sunriseEvents = events.where((e) => e.prayerKey == 'sunrise');
      expect(sunriseEvents, isEmpty);
    });

    test('Reminder is scheduled exactly 10 minutes prior to prayer time', () {
      final now = DateTime(2026, 9, 7, 0, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      final dhuhrReminder = events.firstWhere(
        (e) => e.prayerKey == 'dhuhr' && e.eventType == 'reminder',
      );

      final expectedEpoch = DateTime(2026, 9, 7, 11, 50).millisecondsSinceEpoch;
      expect(dhuhrReminder.epochMillis, expectedEpoch);
    });

    test('Past events are omitted', () {
      // 14:00 -> Fajr, Sunrise, Dhuhr are in the past
      final now = DateTime(2026, 9, 7, 14, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      expect(events.any((e) => e.prayerKey == 'fajr' && e.epochMillis < now.millisecondsSinceEpoch), isFalse);
      expect(events.any((e) => e.prayerKey == 'dhuhr' && e.epochMillis < now.millisecondsSinceEpoch), isFalse);
      // Upcoming today: Asr, Maghrib, Isha
      expect(events.any((e) => e.prayerKey == 'asr'), isTrue);
    });

    test('Alarm IDs are deterministic and collision-free', () {
      final now = DateTime(2026, 9, 7, 0, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      final ids = events.map((e) => e.alarmId).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length, reason: 'All alarm IDs must be unique');
    });

    test('Fajr adhan uses fajr resource and non-Fajr adhan uses regular resource', () {
      final now = DateTime(2026, 9, 7, 0, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      final fajrAdhan = events.firstWhere((e) => e.prayerKey == 'fajr' && e.eventType == 'adhan');
      expect(fajrAdhan.reciterRawResource, AdhanReciter.defaultReciter.fajrRawResourceName);

      final dhuhrAdhan = events.firstWhere((e) => e.prayerKey == 'dhuhr' && e.eventType == 'adhan');
      expect(dhuhrAdhan.reciterRawResource, AdhanReciter.defaultReciter.rawResourceName);

      final asrAdhan = events.firstWhere((e) => e.prayerKey == 'asr' && e.eventType == 'adhan');
      expect(asrAdhan.reciterRawResource, AdhanReciter.defaultReciter.rawResourceName);
    });

    test('Reminders use dedicated reminder_<prayerKey> audio resource', () {
      final now = DateTime(2026, 9, 7, 0, 0);
      final events = planner.planEvents(
        snapshot: snapshot,
        reciter: AdhanReciter.defaultReciter,
        now: now,
      );

      final dhuhrReminder = events.firstWhere((e) => e.prayerKey == 'dhuhr' && e.eventType == 'reminder');
      expect(dhuhrReminder.reciterRawResource, 'reminder_dhuhr');

      final fajrReminder = events.firstWhere((e) => e.prayerKey == 'fajr' && e.eventType == 'reminder');
      expect(fajrReminder.reciterRawResource, 'reminder_fajr');
    });
  });
}
