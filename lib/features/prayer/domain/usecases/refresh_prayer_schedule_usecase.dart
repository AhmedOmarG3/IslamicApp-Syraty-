import 'package:flutter/foundation.dart';
import '../../../../core/services/prayer_scheduler_interface.dart';
import '../repositories/prayer_repository.dart';
import '../services/prayer_event_planner.dart';

class RefreshPrayerScheduleUseCase {
  final PrayerRepository repository;
  final PrayerSchedulerInterface scheduler;
  final PrayerEventPlanner planner;

  RefreshPrayerScheduleUseCase({
    required this.repository,
    required this.scheduler,
    this.planner = const PrayerEventPlanner(),
  });

  Future<void> call({DateTime? currentTime}) async {
    final enabled = await repository.getNotificationsEnabled();
    if (!enabled) {
      debugPrint('[SiratyScheduler] Notifications disabled — cancelling all alarms');
      await scheduler.cancelAllPrayerEvents();
      await scheduler.updateWidget();
      return;
    }

    final now = currentTime ?? DateTime.now();
    final snapshot = await repository.getPrayerSnapshot();
    final reciter = await repository.getSelectedReciter();
    final fajrReciter = await repository.getSelectedFajrReciter();

    final events = planner.planEvents(
      snapshot: snapshot,
      reciter: reciter,
      fajrReciter: fajrReciter,
      now: now,
    );

    debugPrint('[SiratyScheduler] Scheduling ${events.length} events (regular: ${reciter.id}, fajr: ${fajrReciter.id})');
    for (final e in events) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e.epochMillis);
      debugPrint('  → [${e.eventType}] ${e.prayerKey} at $dt (id: ${e.alarmId})');
    }

    final success = await scheduler.scheduleEvents(events);
    debugPrint('[SiratyScheduler] scheduleEvents result: $success');
    await scheduler.updateWidget();
  }
}
