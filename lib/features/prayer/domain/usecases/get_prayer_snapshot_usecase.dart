import '../../data/models/prayer_snapshot_model.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerSnapshotUseCase {
  final PrayerRepository repository;

  GetPrayerSnapshotUseCase({required this.repository});

  Future<PrayerSnapshotModel> call({bool forceRecalculate = false}) async {
    return await repository.getPrayerSnapshot(forceRecalculate: forceRecalculate);
  }
}
