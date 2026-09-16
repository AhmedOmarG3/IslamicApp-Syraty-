import '../../domain/entities/prayer_day.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/entities/prayer_time.dart';

class PrayerDayModel {
  final DateTime date;
  final PrayerLocation location;
  final List<PrayerTime> times;

  const PrayerDayModel({
    required this.date,
    required this.location,
    required this.times,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'location': location.toJson(),
      'times': times
          .map((t) => {
                'key': t.key.name,
                'time': t.time.toIso8601String(),
              })
          .toList(),
    };
  }

  factory PrayerDayModel.fromJson(Map<String, dynamic> json) {
    final location = PrayerLocation.fromJson(
      json['location'] as Map<String, dynamic>,
    );
    final date = DateTime.parse(json['date'] as String);
    final rawTimes = json['times'] as List<dynamic>;

    final times = rawTimes.map((item) {
      final map = item as Map<String, dynamic>;
      return PrayerTime(
        key: PrayerType.values.firstWhere((e) => e.name == map['key']),
        time: DateTime.parse(map['time'] as String),
      );
    }).toList();

    return PrayerDayModel(
      date: date,
      location: location,
      times: times,
    );
  }

  PrayerDay toEntity() {
    return PrayerDay(
      date: date,
      location: location,
      times: times,
    );
  }

  factory PrayerDayModel.fromEntity(PrayerDay entity) {
    return PrayerDayModel(
      date: entity.date,
      location: entity.location,
      times: entity.times,
    );
  }
}
