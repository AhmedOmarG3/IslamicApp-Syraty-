import 'package:siraty/features/prayer/domain/entities/prayer_entity.dart';

abstract class PrayerRepository {
  Future<PrayerTimingsEntity?> getPrayerTimings({
    required String city,
    required String country,
  });
}
