import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/core/services/prayer_scheduler_interface.dart';
import 'package:siraty/features/prayer/domain/usecases/refresh_prayer_schedule_usecase.dart';
import 'package:siraty/features/quran/domain/entities/khatma_model.dart';

class KhatmaService {
  static const String _activeKhatmaKey = 'siraty_active_khatma';
  static const String _khatmaHistoryKey = 'siraty_khatma_history';
  static const int khatmaReminderAlarmId = 99901;

  static final ValueNotifier<KhatmaModel?> activeKhatmaNotifier =
      ValueNotifier<KhatmaModel?>(null);

  /// Initialize and load saved Khatma from SharedPreferences
  static Future<void> init([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final raw = p.getString(_activeKhatmaKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final model = KhatmaModel.fromJson(map);
        activeKhatmaNotifier.value = model;
        if (model.reminderEnabled && !model.isCompleted) {
          scheduleReminder(model);
        }
      } catch (e) {
        debugPrint('Error parsing active khatma: $e');
      }
    }
  }

  /// Start a new Khatma with optional daily reminder
  static Future<KhatmaModel> startKhatma({
    required int targetDays,
    int startPage = 1,
    String? customTitle,
    bool reminderEnabled = true,
    int reminderHour = 21,
    int reminderMinute = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final title = customTitle ?? 'ختمة الـ $targetDays يوماً';
    final khatma = KhatmaModel(
      id: 'khatma_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetDays: targetDays,
      startDate: DateTime.now(),
      startPage: startPage,
      currentPage: startPage,
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );

    await prefs.setString(_activeKhatmaKey, jsonEncode(khatma.toJson()));
    activeKhatmaNotifier.value = khatma;

    if (reminderEnabled) {
      await scheduleReminder(khatma);
    }

    return khatma;
  }

  /// Update active Khatma plan while strictly preserving user reading progress
  static Future<KhatmaModel> updateKhatmaPlan({
    required int newTargetDays,
    int? customDailyPages,
    String? customTitle,
    required bool reminderEnabled,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    final current = activeKhatmaNotifier.value;
    if (current == null) {
      throw StateError('No active khatma to update');
    }

    final title = customTitle ?? current.title;
    final updated = current.copyWith(
      targetDays: newTargetDays,
      customDailyPages: customDailyPages,
      title: title,
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKhatmaKey, jsonEncode(updated.toJson()));
    activeKhatmaNotifier.value = updated;

    if (reminderEnabled) {
      await scheduleReminder(updated);
    }

    return updated;
  }

  /// Schedule or update the daily notification reminder for the Khatma
  static Future<void> scheduleReminder([KhatmaModel? khatma]) async {
    final model = khatma ?? activeKhatmaNotifier.value;
    if (model == null || !model.reminderEnabled || model.isCompleted) return;

    try {
      final scheduler = getIt<PrayerSchedulerInterface>();
      final hasPerm = await scheduler.hasNotificationPermission();
      if (!hasPerm) return;

      final now = DateTime.now();
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        model.reminderHour,
        model.reminderMinute,
      );

      // If today's reminder time has already passed, schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final payload = PrayerEventPayload(
        alarmId: khatmaReminderAlarmId,
        epochMillis: scheduled.millisecondsSinceEpoch,
        prayerKey: 'khatma',
        eventType: 'reminder',
        reciterRawResource: '',
        title: 'وِرد القرآن الكريم 🌙',
        body: 'حان وقت وردك اليومي، اقرأ وردك لتواصل تقدّمك في ${model.title}',
      );

      await scheduler.scheduleEvents([payload]);
      debugPrint('[KhatmaReminder] Scheduled next reminder at: $scheduled');
    } catch (e) {
      debugPrint('Error scheduling khatma reminder: $e');
    }
  }

  /// Update user progress if a new page is read
  static Future<void> updateCurrentPage(int page, {bool forceUpdate = false}) async {
    final current = activeKhatmaNotifier.value;
    if (current == null) return;
    if (!forceUpdate && page <= current.currentPage) return; // Only advance forward

    final clampedPage = page.clamp(1, 604);
    final isDone = clampedPage >= 604;

    final updated = current.copyWith(
      currentPage: clampedPage,
      lastReadDate: DateTime.now(),
      completedAt: isDone ? DateTime.now() : current.completedAt,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKhatmaKey, jsonEncode(updated.toJson()));
    activeKhatmaNotifier.value = updated;

    if (isDone) {
      await _archiveCompletedKhatma(updated, prefs);
    }
  }

  /// Mark today's entire wird as completed (e.g. read from physical Mushaf)
  /// or complete tomorrow's/extra wird if [targetEndPage] is specified.
  static Future<void> completeTodayWird([int? targetEndPage]) async {
    final current = activeKhatmaNotifier.value;
    if (current == null) return;

    final target = targetEndPage ??
        (current.isTodayWirdDone
            ? current.nextWirdRange.$2
            : current.todayWirdRange.$2);
    await updateCurrentPage(target, forceUpdate: true);
  }

  /// Delete or reset active Khatma
  static Future<void> deleteKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKhatmaKey);
    activeKhatmaNotifier.value = null;
    try {
      final refresh = getIt<RefreshPrayerScheduleUseCase>();
      await refresh();
    } catch (_) {}
  }

  /// Archive completed Khatma to history
  static Future<void> _archiveCompletedKhatma(
    KhatmaModel khatma,
    SharedPreferences prefs,
  ) async {
    try {
      final historyList = prefs.getStringList(_khatmaHistoryKey) ?? [];
      historyList.add(jsonEncode(khatma.toJson()));
      await prefs.setStringList(_khatmaHistoryKey, historyList);
    } catch (e) {
      debugPrint('Error archiving khatma: $e');
    }
  }
}
