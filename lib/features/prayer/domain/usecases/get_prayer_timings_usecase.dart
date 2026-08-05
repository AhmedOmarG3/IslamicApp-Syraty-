import 'package:siraty/features/prayer/domain/entities/prayer_entity.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';

class GetPrayerTimingsUseCase {
  final PrayerRepository repository;

  GetPrayerTimingsUseCase({required this.repository});

  Future<PrayerTimingsEntity?> call({
    required String city,
    required String country,
  }) async {
    return await repository.getPrayerTimings(city: city, country: country);
  }
}
