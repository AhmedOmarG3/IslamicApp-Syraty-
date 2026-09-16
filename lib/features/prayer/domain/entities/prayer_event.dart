import 'package:equatable/equatable.dart';
import 'prayer_time.dart';

enum PrayerEventType {
  reminder,
  adhan,
}

class PrayerEvent extends Equatable {
  final PrayerType prayer;
  final PrayerEventType eventType;
  final DateTime date;
  final DateTime scheduledAt;
  final int alarmId;

  const PrayerEvent({
    required this.prayer,
    required this.eventType,
    required this.date,
    required this.scheduledAt,
    required this.alarmId,
  });

  /// Generates a deterministic, collision-free integer alarm ID based on:
  /// day-of-year (1..366) * 100 + prayerIndex (0..5) * 10 + eventTypeIndex (0..1).
  /// This ensures that rescheduling the same event replaces the previous alarm in AlarmManager.
  static int generateAlarmId(DateTime date, PrayerType prayer, PrayerEventType type) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays + 1;
    final prayerCode = prayer.index;
    final typeCode = type == PrayerEventType.reminder ? 1 : 2;
    return (dayOfYear * 1000) + (prayerCode * 10) + typeCode;
  }

  factory PrayerEvent.create({
    required PrayerType prayer,
    required PrayerEventType eventType,
    required DateTime prayerTime,
    required DateTime date,
  }) {
    final scheduledAt = eventType == PrayerEventType.reminder
        ? prayerTime.subtract(const Duration(minutes: 10))
        : prayerTime;

    return PrayerEvent(
      prayer: prayer,
      eventType: eventType,
      date: date,
      scheduledAt: scheduledAt,
      alarmId: generateAlarmId(date, prayer, eventType),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prayer': prayer.name,
      'eventType': eventType.name,
      'date': date.toIso8601String(),
      'scheduledAt': scheduledAt.toIso8601String(),
      'alarmId': alarmId,
    };
  }

  factory PrayerEvent.fromJson(Map<String, dynamic> json) {
    return PrayerEvent(
      prayer: PrayerType.values.firstWhere((e) => e.name == json['prayer']),
      eventType: PrayerEventType.values.firstWhere((e) => e.name == json['eventType']),
      date: DateTime.parse(json['date']),
      scheduledAt: DateTime.parse(json['scheduledAt']),
      alarmId: json['alarmId'] as int,
    );
  }

  @override
  List<Object?> get props => [prayer, eventType, date, scheduledAt, alarmId];
}
