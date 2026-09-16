import '../../domain/entities/calculation_method_setting.dart';
import '../../domain/entities/prayer_day.dart';
import '../../domain/entities/prayer_location.dart';
import 'prayer_day_model.dart';

class PrayerSnapshotModel {
  final PrayerDay today;
  final PrayerDay tomorrow;
  final PrayerLocation location;
  final CalculationMethodSetting method;
  final DateTime generatedAt;

  const PrayerSnapshotModel({
    required this.today,
    required this.tomorrow,
    required this.location,
    required this.method,
    required this.generatedAt,
  });

  bool isStale(DateTime now) {
    // Stale if today is from a previous calendar day
    final todayDate = DateTime(today.date.year, today.date.month, today.date.day);
    final nowDate = DateTime(now.year, now.month, now.day);
    return nowDate.isAfter(todayDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'today': PrayerDayModel.fromEntity(today).toJson(),
      'tomorrow': PrayerDayModel.fromEntity(tomorrow).toJson(),
      'location': location.toJson(),
      'method': method.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory PrayerSnapshotModel.fromJson(Map<String, dynamic> json) {
    return PrayerSnapshotModel(
      today: PrayerDayModel.fromJson(json['today'] as Map<String, dynamic>).toEntity(),
      tomorrow: PrayerDayModel.fromJson(json['tomorrow'] as Map<String, dynamic>).toEntity(),
      location: PrayerLocation.fromJson(json['location'] as Map<String, dynamic>),
      method: CalculationMethodSetting.fromJson(json['method'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}
