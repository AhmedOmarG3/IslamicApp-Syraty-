import '../entities/prayer_time.dart';
import '../repositories/prayer_repository.dart';

class NextPrayerResult {
  final PrayerTime prayer;
  final bool isTomorrow;
  final Duration timeRemaining;

  const NextPrayerResult({
    required this.prayer,
    required this.isTomorrow,
    required this.timeRemaining,
  });
}

class GetNextPrayerUseCase {
  final PrayerRepository repository;

  GetNextPrayerUseCase({required this.repository});

  Future<NextPrayerResult?> call([DateTime? currentTime]) async {
    final now = currentTime ?? DateTime.now();
    final snapshot = await repository.getPrayerSnapshot();

    // 1. Try today's next prayer (excluding sunrise)
    final todayNext = snapshot.today.nextPrayer(now, includeSunrise: false);
    if (todayNext != null) {
      return NextPrayerResult(
        prayer: todayNext,
        isTomorrow: false,
        timeRemaining: todayNext.time.difference(now),
      );
    }

    // 2. Past Isha today -> next prayer is Tomorrow's Fajr
    final tomorrowFajr = snapshot.tomorrow.getTime(PrayerType.fajr);
    if (tomorrowFajr != null) {
      return NextPrayerResult(
        prayer: tomorrowFajr,
        isTomorrow: true,
        timeRemaining: tomorrowFajr.time.difference(now),
      );
    }

    return null;
  }
}
