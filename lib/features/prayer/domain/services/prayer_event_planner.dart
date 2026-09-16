import '../../../../core/services/prayer_scheduler_interface.dart';
import '../../data/models/prayer_snapshot_model.dart';
import '../entities/adhan_reciter.dart';
import '../entities/prayer_event.dart';
import '../entities/prayer_time.dart';

class PrayerEventPlanner {
  const PrayerEventPlanner();

  List<PrayerEventPayload> planEvents({
    required PrayerSnapshotModel snapshot,
    required AdhanReciter reciter,
    AdhanReciter? fajrReciter,
    required DateTime now,
  }) {
    final payloads = <PrayerEventPayload>[];

    // Combine today and tomorrow prayers
    final days = [snapshot.today, snapshot.tomorrow];

    for (final day in days) {
      for (final prayerTime in day.times) {
        // Exclude sunrise
        if (!prayerTime.isPrayer) continue;

        // 1. Reminder event (10 minutes before)
        final reminderTime = prayerTime.time.subtract(const Duration(minutes: 10));
        if (reminderTime.isAfter(now)) {
          final alarmId = PrayerEvent.generateAlarmId(
            day.date,
            prayerTime.key,
            PrayerEventType.reminder,
          );
          payloads.add(PrayerEventPayload(
            alarmId: alarmId,
            epochMillis: reminderTime.millisecondsSinceEpoch,
            prayerKey: prayerTime.key.name,
            eventType: 'reminder',
            reciterRawResource: 'reminder_${prayerTime.key.name}',
            title: 'اقترب موعد صلاة ${prayerTime.arabicName}',
            body: 'بقي ١٠ دقائق على أذان ${prayerTime.arabicName}',
          ));
        }

        // 2. Adhan event (exact time)
        if (prayerTime.time.isAfter(now)) {
          final isFajr = prayerTime.key == PrayerType.fajr;
          final activeReciter = isFajr ? (fajrReciter ?? reciter) : reciter;
          final alarmId = PrayerEvent.generateAlarmId(
            day.date,
            prayerTime.key,
            PrayerEventType.adhan,
          );
          payloads.add(PrayerEventPayload(
            alarmId: alarmId,
            epochMillis: prayerTime.time.millisecondsSinceEpoch,
            prayerKey: prayerTime.key.name,
            eventType: 'adhan',
            reciterRawResource: activeReciter.getRawResourceFor(isFajr: isFajr),
            title: 'حان الآن موعد أذان ${prayerTime.arabicName}',
            body: isFajr ? 'الصلاة خير من النوم' : 'حي على الصلاة، حي على الفلاح',
          ));
        }
      }
    }

    return payloads;
  }
}
