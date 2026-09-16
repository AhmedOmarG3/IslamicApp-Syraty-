import 'package:flutter/services.dart';
import 'prayer_scheduler_interface.dart';

class NativePrayerScheduler implements PrayerSchedulerInterface {
  static const MethodChannel _channel = MethodChannel('siraty/prayer_scheduler');

  const NativePrayerScheduler();

  @override
  Future<bool> scheduleEvents(List<PrayerEventPayload> events) async {
    try {
      final List<Map<String, dynamic>> serialized =
          events.map((e) => e.toMap()).toList();
      final result = await _channel.invokeMethod<bool>(
        'scheduleEvents',
        {'events': serialized},
      );
      return result ?? true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> cancelAllPrayerEvents() async {
    try {
      await _channel.invokeMethod<void>('cancelAllPrayerEvents');
    } catch (_) {}
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestExactAlarmPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestNotificationPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('hasNotificationPermission');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod<void>('updateWidget');
    } catch (_) {}
  }

  @override
  Future<String> getDeviceManufacturer() async {
    try {
      final result = await _channel.invokeMethod<String>('getDeviceManufacturer');
      return result ?? 'الهاتف';
    } catch (_) {
      return 'الهاتف';
    }
  }

  @override
  Future<bool> isAutoStartSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAutoStartSupported');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openAutoStartSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openAutoStartSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
