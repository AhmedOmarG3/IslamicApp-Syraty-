import 'package:equatable/equatable.dart';
import 'prayer_location.dart';
import 'prayer_time.dart';

class PrayerDay extends Equatable {
  final DateTime date;
  final PrayerLocation location;
  final List<PrayerTime> times;

  const PrayerDay({
    required this.date,
    required this.location,
    required this.times,
  });

  PrayerTime? getTime(PrayerType type) {
    for (final t in times) {
      if (t.key == type) return t;
    }
    return null;
  }

  /// Returns the current active prayer (excluding sunrise).
  PrayerTime? currentPrayer(DateTime now) {
    final fajr = getTime(PrayerType.fajr)?.time;
    final sunrise = getTime(PrayerType.sunrise)?.time;
    final dhuhr = getTime(PrayerType.dhuhr)?.time;
    final asr = getTime(PrayerType.asr)?.time;
    final maghrib = getTime(PrayerType.maghrib)?.time;
    final isha = getTime(PrayerType.isha)?.time;

    if (fajr == null || sunrise == null || dhuhr == null || asr == null || maghrib == null || isha == null) {
      return null;
    }

    const activeWindow = Duration(minutes: 25);

    if (now.isAfter(fajr) && now.isBefore(fajr.add(activeWindow)) && now.isBefore(sunrise)) {
      return getTime(PrayerType.fajr);
    } else if (now.isAfter(dhuhr) && now.isBefore(dhuhr.add(activeWindow)) && now.isBefore(asr)) {
      return getTime(PrayerType.dhuhr);
    } else if (now.isAfter(asr) && now.isBefore(asr.add(activeWindow)) && now.isBefore(maghrib)) {
      return getTime(PrayerType.asr);
    } else if (now.isAfter(maghrib) && now.isBefore(maghrib.add(activeWindow)) && now.isBefore(isha)) {
      return getTime(PrayerType.maghrib);
    } else if (now.isAfter(isha) && now.isBefore(isha.add(activeWindow))) {
      return getTime(PrayerType.isha);
    }
    return null;
  }

  /// Returns the next upcoming prayer (excluding sunrise as a prayer destination).
  /// If [includeSunrise] is false (default), nextPrayer will jump from Fajr to Dhuhr after Fajr starts.
  PrayerTime? nextPrayer(DateTime now, {bool includeSunrise = false}) {
    for (final t in times) {
      if (!includeSunrise && t.key == PrayerType.sunrise) continue;
      if (t.time.isAfter(now)) {
        return t;
      }
    }
    return null;
  }

  /// Returns a new PrayerDay with updated derived statuses for the given [now] timestamp.
  PrayerDay withDerivedStatuses(DateTime now) {
    // 1. Find which times are passed vs upcoming
    final updatedTimes = <PrayerTime>[];
    
    // Find active prayer if any
    final current = currentPrayer(now);

    for (var i = 0; i < times.length; i++) {
      final t = times[i];
      PrayerStatus status;

      if (current != null && current.key == t.key) {
        status = PrayerStatus.current;
      } else if (now.isAfter(t.time)) {
        status = PrayerStatus.passed;
      } else {
        status = PrayerStatus.upcoming;
      }

      updatedTimes.add(t.copyWith(status: status));
    }

    return PrayerDay(
      date: date,
      location: location,
      times: updatedTimes,
    );
  }

  @override
  List<Object?> get props => [date, location, times];
}
