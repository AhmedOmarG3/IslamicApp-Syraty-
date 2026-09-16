import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:siraty/app/router/app_router.dart';
import 'package:siraty/core/widgets/islamic_ornament_painter.dart';

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
      final refText = 'سورة ${ayah.surahName} · $arabicAyah';

      // 1. Save data fields for the native widget
      await HomeWidget.saveWidgetData<String>(
          'ayah_text', '﴿ ${ayah.verseText} ﴾');
      await HomeWidget.saveWidgetData<String>('ayah_ref', refText);
      await HomeWidget.saveWidgetData<int>('surah_num', ayah.surahNumber);
      await HomeWidget.saveWidgetData<int>('ayah_num', ayah.ayahNumber);
      // Day key so the native onUpdate can detect day rollover and
      // trigger a background refresh (see AyahWidgetProvider.kt).
      await HomeWidget.saveWidgetData<int>(
        'ayah_day_key',
        DailyAyahService.getDayKey(),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF163E32),
                Color(0xFF0F2B22),
                Color(0xFF091C16),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: CustomPaint(
            painter: const IslamicOrnamentPainter(
              primaryGold: Color(0xFFE2B86E),
              borderWidth: 1.1,
              cornerSize: 15,
              showCornerFlourishes: true,
              showInnerBorder: true,
              showArch: true,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 1),

                  // Header: Title Cartouche
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2B86E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2B86E).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'آيَةُ اليَوْمِ · سِيرَتِي',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF3D295),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  // Ayah Text in AmiriQuran Calligraphy with FittedBox protection
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(
                              '﴿ ${ayah.verseText} ﴾',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: ayah.verseText.length > 110
                                    ? 11.5
                                    : (ayah.verseText.length > 55 ? 13.0 : 15.0),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFAF7EE),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Reference Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2B86E).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE2B86E).withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'سورة ${ayah.surahName} · آية $arabicAyah',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 10,
                        color: Color(0xFFF3D295),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

