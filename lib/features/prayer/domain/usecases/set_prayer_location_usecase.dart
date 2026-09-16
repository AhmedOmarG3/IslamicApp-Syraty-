import '../entities/prayer_location.dart';
import '../repositories/prayer_repository.dart';

class SetPrayerLocationUseCase {
  final PrayerRepository repository;

  SetPrayerLocationUseCase({required this.repository});

  Future<void> call(PrayerLocation location) async {
    await repository.saveLocation(location);
  }
}
