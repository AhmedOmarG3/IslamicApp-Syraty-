import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:siraty/app/router/app_router.dart';

import 'package:siraty/features/home/domain/services/daily_ayah_service.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_card_share_dialog.dart';

/// Entry point invoked by the home_widget background dispatcher when the
/// native widget detects a stale (yesterday's) ayah. Must be a top-level
/// function with [pragma] kept for AOT tree-shaking.
@pragma('vm:entry-point')
Future<void> dailyAyahWidgetBackgroundCallback(Uri? uri) async {
  await DailyAyahWidgetService.updateWidget();
}

class DailyAyahWidgetService {
  static const String androidWidgetName = 'AyahWidgetProvider';
  static Uri? pendingWidgetLaunchUri;

  /// Listens to widget clicks from Android/iOS Home Screen
  static void initializeWidgetLaunchHandler() {
    // Register the background callback so the native widget can ask a
    /// headless Dart isolate to refresh the daily ayah (day rollover).
    HomeWidget.registerInteractivityCallback(dailyAyahWidgetBackgroundCallback);

    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) {
        pendingWidgetLaunchUri = uri;
      }
    });

    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        final currentLoc = AppRouter.router.routerDelegate.currentConfiguration.uri.toString();
        if (currentLoc == '/' || currentLoc == '/splash') {
          pendingWidgetLaunchUri = uri;
        } else {
          executeWidgetAction(uri);
        }
      }
    });
  }

  /// Called after Splash Screen finishes to execute any pending cold-start widget tap
  static void executePendingWidgetAction() {
    final uri = pendingWidgetLaunchUri;
    if (uri != null) {
      pendingWidgetLaunchUri = null;
      // Slight delay to ensure home screen route is mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        executeWidgetAction(uri);
      });
    }
  }

  /// Dispatches the 4 actions: read, listen, tafsir, share
  static Future<void> executeWidgetAction(Uri uri) async {
    if (uri.scheme != 'siraty') return;
    if (uri.host == 'prayer' || uri.queryParameters['action'] == 'prayer') {
      AppRouter.router.go('/prayer');
      return;
    }
    final action = uri.queryParameters['action'] ?? 'home';
    if (action == 'home') {
      AppRouter.router.go('/');
      return;
    }
    final ayah = DailyAyahService.getDailyAyah();

    try {
      if (action == 'share') {
        final ctx = AppRouter.rootNavigatorKey.currentContext;
        if (ctx != null) {
          AyahCardShareDialog.show(
            ctx,
            surahName: ayah.surahName,
            ayahNumber: ayah.ayahNumber,
            verseText: ayah.verseText,
          );
        }
        return;
      }

      final surah = await LastReadService.loadSurah(ayah.surahNumber);
      if (surah == null) return;

      switch (action) {
        case 'listen':
          AppRouter.router.push(
            '/quran-listen',
            extra: {
              'surahNumber': ayah.surahNumber,
              'surahName': ayah.surahName,
              'versesCount': surah.verses.length,
              'initialAyah': ayah.ayahNumber,
            },
          );
          break;

        case 'tafsir':
          AppRouter.router.push(
            '/surah-details',
            extra: {
              'surah': surah,
              'surahName': ayah.surahName,
              'targetAyah': ayah.ayahNumber,
              'autoOpenTafsir': true,
            },
          );
          break;

        case 'read':
        default:
          AppRouter.router.push(
            '/surah-details',
            extra: {
              'surah': surah,
              'surahName': ayah.surahName,
              'targetAyah': ayah.ayahNumber,
            },
          );
          break;
      }
    } catch (e) {
      debugPrint('Error executing widget action ($action): $e');
    }
  }

  /// Updates the Android & iOS home screen widgets with today's Ayah
  static Future<void> updateWidget() async {
    try {
      final ayah = DailyAyahService.getDailyAyah();
      final arabicAyah = QuranMetadata.toArabicDigits(ayah.ayahNumber);
      final cleanVerse =
          ayah.verseText.replaceAll('﴿', '').replaceAll('﴾', '').trim();
      final refText = 'سورة ${ayah.surahName} · آية $arabicAyah';

      // 1. Save data fields for the native widget
      await HomeWidget.saveWidgetData<String>(
          'ayah_text', '﴿ $cleanVerse ﴾');
      await HomeWidget.saveWidgetData<String>('ayah_ref', refText);
      await HomeWidget.saveWidgetData<int>('surah_num', ayah.surahNumber);
      await HomeWidget.saveWidgetData<int>('ayah_num', ayah.ayahNumber);
      // Day key so the native onUpdate can detect day rollover and
      // trigger a background refresh (see AyahWidgetProvider.kt).
      await HomeWidget.saveWidgetData<int>(
        'ayah_day_key',
        DailyAyahService.getDayKey(),
      );

      // Save curated verses as JSON so native Android can autonomously rotate verses at midnight
      final allVerses = DailyAyahService.getAllCuratedVerses();
      final versesJson = jsonEncode(allVerses
          .map((v) => {
                'surahNumber': v.surahNumber,
                'surahName': v.surahName,
                'ayahNumber': v.ayahNumber,
                'verseText': v.verseText,
              })
          .toList());
      await HomeWidget.saveWidgetData<String>(
        'daily_ayah_curated_json',
        versesJson,
      );

      // 2. Render the offscreen Flutter card into a high-res image
      await HomeWidget.renderFlutterWidget(
        DailyAyahWidgetCard(ayah: ayah, arabicAyah: arabicAyah),
        key: 'ayah_widget_image',
        logicalSize: const Size(360, 160),
        pixelRatio: 2.5,
      );


      // 3. Request native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating Daily Ayah Home Widget: $e');
    }
  }
}

/// The offscreen Flutter widget rendered directly into the home screen widget image
class DailyAyahWidgetCard extends StatelessWidget {
  final DailyAyahModel ayah;
  final String arabicAyah;

  const DailyAyahWidgetCard({
    super.key,
    required this.ayah,
    required this.arabicAyah,
  });

  @override
  Widget build(BuildContext context) {
    final cleanVerse =
        ayah.verseText.replaceAll('﴿', '').replaceAll('﴾', '').trim();

    return MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 160),
        textScaler: TextScaler.noScaling,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          height: 160,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF15382E),
                Color(0xFF0D251E),
                Color(0xFF081814),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2B86E).withValues(alpha: 0.25),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Header: "✦ آية اليوم" on right & Surah Reference on left
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '✦ آية اليوم',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF3D295),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2B86E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2B86E).withValues(alpha: 0.2),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        'سورة ${ayah.surahName} · آية $arabicAyah',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5C78A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              // Subtle Divider
              Container(
                height: 0.8,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 5),
              // Ayah in authentic Quranic calligraphy
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 328),
                      child: Text(
                        '﴿ $cleanVerse ﴾',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: cleanVerse.length > 130
                              ? 13.5
                              : (cleanVerse.length > 70 ? 15.0 : 17.5),
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFFAF7EE),
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
