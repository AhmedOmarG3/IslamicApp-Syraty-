import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:siraty/app/app.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/features/home/domain/services/daily_ayah_widget_service.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:siraty/features/prayer/domain/services/prayer_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await setupServiceLocator();
  // Refresh home screen widgets
  DailyAyahWidgetService.updateWidget().catchError((e) {
    debugPrint('Widget init skipped or error: $e');
  });
  DailyAyahWidgetService.initializeWidgetLaunchHandler();

  try {
    final prayerRepo = getIt<PrayerRepository>();
    prayerRepo.getPrayerSnapshot().then((snapshot) {
      PrayerWidgetService.updateWidget(snapshot: snapshot).catchError((e) {
        debugPrint('Prayer widget update error: $e');
      });
    });
  } catch (e) {
    debugPrint('Prayer widget init error: $e');
  }

  runApp(
    const SiratyApp(),
  );
}
