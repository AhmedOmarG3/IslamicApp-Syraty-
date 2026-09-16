import '../../data/models/prayer_snapshot_model.dart';
import '../entities/adhan_reciter.dart';
import '../entities/calculation_method_setting.dart';
import '../entities/prayer_entity.dart';
import '../entities/prayer_location.dart';

abstract class PrayerRepository {
  Future<PrayerSnapshotModel> getPrayerSnapshot({bool forceRecalculate = false});
  Future<PrayerLocation> getSavedLocation();
  Future<void> saveLocation(PrayerLocation location);
  Future<CalculationMethodSetting> getCalculationMethodSetting();
  Future<void> saveCalculationMethodSetting(CalculationMethodSetting setting);
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<AdhanReciter> getSelectedReciter();
  Future<void> setSelectedReciter(String reciterId);
  Future<AdhanReciter> getSelectedFajrReciter();
  Future<void> setSelectedFajrReciter(String reciterId);

  /// Backward-compatibility helper for any legacy consumers
  Future<PrayerTimingsEntity?> getPrayerTimings({
    required String city,
    required String country,
  });
}
