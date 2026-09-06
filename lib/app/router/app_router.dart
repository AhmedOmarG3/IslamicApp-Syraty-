import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/app/presentation/pages/main_scaffold_page.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/presentation/pages/azkar_page.dart';
import 'package:siraty/features/azkar/presentation/pages/hisn_al_muslim_page.dart';
import 'package:siraty/features/azkar/presentation/pages/zekr_page.dart';
import 'package:siraty/features/home/presentation/pages/favorites_page.dart';
import 'package:siraty/features/home/presentation/pages/home_page.dart';
import 'package:siraty/features/home/presentation/pages/zakat_page.dart';
import 'package:siraty/features/prayer/presentation/pages/hijri_page.dart';
import 'package:siraty/features/prayer/presentation/pages/prayer_page.dart';
import 'package:siraty/features/prayer/presentation/pages/qibla_page.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/presentation/pages/khatma_page.dart';
import 'package:siraty/features/quran/presentation/pages/quran_audio_player_page.dart';
import 'package:siraty/features/quran/presentation/pages/quran_page.dart';
import 'package:siraty/features/quran/presentation/pages/quran_search_page.dart';
import 'package:siraty/features/quran/presentation/pages/surah_page.dart';
import 'package:siraty/features/settings/presentation/pages/settings_page.dart';
import 'package:siraty/features/splash/presentation/pages/splash_page.dart';
import 'package:siraty/features/tasbeeh/presentation/pages/tasbeeh_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          // 0: الرئيسية (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 1: القرآن (Quran)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quran',
                builder: (context, state) => const QuranPage(),
              ),
            ],
          ),
          // 2: السبحة (Tasbeeh)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasbeeh',
                builder: (context, state) => const TasbeehPage(),
              ),
            ],
          ),
          // 3: الصلاة (Prayer)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prayer',
                builder: (context, state) => const PrayerPage(),
              ),
            ],
          ),
          // 4: الإعدادات (Settings)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      // Detail & Sub-feature routes
      GoRoute(
        path: '/surah-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return SurahPage(
            surah: args['surah'] as SurahModel,
            surahName: args['surahName'] as String,
            initialPage: args['initialPage'] as int?,
            targetAyah: args['targetAyah'] as int?,
          );
        },
      ),
      GoRoute(
        path: '/quran-search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuranSearchPage(),
      ),
      GoRoute(
        path: '/quran-listen',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return QuranAudioPlayerPage(
            surahNumber: args?['surahNumber'] as int? ?? 1,
            surahName: args?['surahName'] as String? ?? 'الفاتحة',
            versesCount: args?['versesCount'] as int? ?? 7,
            initialAyah: args?['initialAyah'] as int? ?? 1,
          );
        },
      ),
      GoRoute(
        path: '/azkar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AzkarPage(),
      ),
      GoRoute(
        path: '/zekr-details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final zekr = state.extra as AzkarModel;
          return ZekrPage(zekr: zekr);
        },
      ),
      GoRoute(
        path: '/qibla',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QiblaPage(),
      ),
      GoRoute(
        path: '/khatma',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const KhatmaPage(),
      ),
      GoRoute(
        path: '/hisn-al-muslim',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HisnAlMuslimPage(),
      ),
      GoRoute(
        path: '/zakat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ZakatPage(),
      ),
      GoRoute(
        path: '/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/hijri',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HijriPage(),
      ),
    ],
  );
}
