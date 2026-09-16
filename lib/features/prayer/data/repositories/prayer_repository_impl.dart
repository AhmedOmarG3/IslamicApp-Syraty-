import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/adhan_reciter.dart';
import '../../domain/entities/calculation_method_setting.dart';
import '../../domain/entities/prayer_entity.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasource/prayer_calculation_data_source.dart';
import '../models/prayer_snapshot_model.dart';
import '../../domain/services/prayer_widget_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerCalculationDataSource calculationDataSource;
  final SharedPreferences sharedPreferences;

  static const _keyLocation = 'prayer.location';
  static const _keyMethod = 'prayer.method';
  static const _keySnapshot = 'prayer.snapshot';
  static const _keyNotifications = 'prayer.notifications_enabled';
  static const _keyReciter = 'prayer.selected_reciter';
  static const _keyFajrReciter = 'prayer.selected_fajr_reciter';

  PrayerRepositoryImpl({
    required this.calculationDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<PrayerSnapshotModel> getPrayerSnapshot({bool forceRecalculate = false}) async {
    final now = DateTime.now();

    if (!forceRecalculate) {
      final cachedJson = sharedPreferences.getString(_keySnapshot);
      if (cachedJson != null) {
        try {
          final snapshot = PrayerSnapshotModel.fromJson(
            json.decode(cachedJson) as Map<String, dynamic>,
          );
          if (!snapshot.isStale(now)) {
            return snapshot;
          }
        } catch (_) {
          // Stale or corrupted cache -> recalculate
        }
      }
    }

    final location = await getSavedLocation();
    final methodSetting = await getCalculationMethodSetting();

    final today = calculationDataSource.calculatePrayerDay(
      location: location,
      setting: methodSetting,
      date: now,
    );

    final tomorrowDate = now.add(const Duration(days: 1));
    final tomorrow = calculationDataSource.calculatePrayerDay(
      location: location,
      setting: methodSetting,
      date: tomorrowDate,
    );

    final snapshot = PrayerSnapshotModel(
      today: today,
      tomorrow: tomorrow,
      location: location,
      method: methodSetting,
      generatedAt: now,
    );

    await sharedPreferences.setString(_keySnapshot, json.encode(snapshot.toJson()));
    PrayerWidgetService.updateWidget(snapshot: snapshot).catchError((_) {});
    return snapshot;
  }

  @override
  Future<PrayerLocation> getSavedLocation() async {
    final jsonStr = sharedPreferences.getString(_keyLocation);
    if (jsonStr != null) {
      try {
        return PrayerLocation.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    return PrayerLocation.defaultLocation;
  }

  @override
  Future<void> saveLocation(PrayerLocation location) async {
    await sharedPreferences.setString(_keyLocation, json.encode(location.toJson()));
    // Invalidate and regenerate snapshot
    await getPrayerSnapshot(forceRecalculate: true);
  }

  @override
  Future<CalculationMethodSetting> getCalculationMethodSetting() async {
    final jsonStr = sharedPreferences.getString(_keyMethod);
    if (jsonStr != null) {
      try {
        return CalculationMethodSetting.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return const CalculationMethodSetting();
  }

  @override
  Future<void> saveCalculationMethodSetting(CalculationMethodSetting setting) async {
    await sharedPreferences.setString(_keyMethod, json.encode(setting.toJson()));
    // Invalidate and regenerate snapshot
    await getPrayerSnapshot(forceRecalculate: true);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    return sharedPreferences.getBool(_keyNotifications) ?? false;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await sharedPreferences.setBool(_keyNotifications, enabled);
  }

  @override
  Future<AdhanReciter> getSelectedReciter() async {
    final id = sharedPreferences.getString(_keyReciter) ?? 'makkah';
    return AdhanReciter.getById(id);
  }

  @override
  Future<void> setSelectedReciter(String reciterId) async {
    await sharedPreferences.setString(_keyReciter, reciterId);
  }

  @override
  Future<AdhanReciter> getSelectedFajrReciter() async {
    final id = sharedPreferences.getString(_keyFajrReciter) ?? 'makkah';
    return AdhanReciter.getById(id);
  }

  @override
  Future<void> setSelectedFajrReciter(String reciterId) async {
    await sharedPreferences.setString(_keyFajrReciter, reciterId);
  }

  @override
  Future<PrayerTimingsEntity?> getPrayerTimings({
    required String city,
    required String country,
  }) async {
    final snapshot = await getPrayerSnapshot();
    final formatter = DateFormat('hh:mm a', 'ar');

    final azanTimes = snapshot.today.times
        .map((t) => formatter.format(t.time))
        .toList();
    final timesName = snapshot.today.times
        .map((t) => t.arabicName)
        .toList();

    return PrayerTimingsEntity(
      azanTimes: azanTimes,
      timesName: timesName,
    );
  }
}
