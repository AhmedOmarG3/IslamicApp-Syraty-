import 'package:equatable/equatable.dart';

class PrayerEventPayload extends Equatable {
  final int alarmId;
  final int epochMillis;
  final String prayerKey;
  final String eventType; // "reminder" | "adhan"
  final String reciterRawResource;
  final String title;
  final String body;

  const PrayerEventPayload({
    required this.alarmId,
    required this.epochMillis,
    required this.prayerKey,
    required this.eventType,
    required this.reciterRawResource,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'alarmId': alarmId,
      'epochMillis': epochMillis,
      'prayerKey': prayerKey,
      'eventType': eventType,
      'reciterRawResource': reciterRawResource,
      'title': title,
      'body': body,
    };
  }

  @override
  List<Object?> get props => [
        alarmId,
        epochMillis,
        prayerKey,
        eventType,
        reciterRawResource,
        title,
        body,
      ];
}

abstract class PrayerSchedulerInterface {
  Future<bool> scheduleEvents(List<PrayerEventPayload> events);
  Future<void> cancelAllPrayerEvents();
  Future<bool> canScheduleExactAlarms();
  Future<bool> requestExactAlarmPermission();
  Future<bool> requestNotificationPermission();
  Future<bool> hasNotificationPermission();
  Future<bool> isIgnoringBatteryOptimizations();
  Future<bool> requestIgnoreBatteryOptimizations();
  Future<void> updateWidget();
  Future<String> getDeviceManufacturer();
  Future<bool> isAutoStartSupported();
  Future<bool> openAutoStartSettings();
  Future<void> updateOngoingNotification();
  Future<void> setOngoingNotificationEnabled(bool enabled);
}
