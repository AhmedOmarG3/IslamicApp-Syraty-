import 'package:go_router/go_router.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/presentation/pages/azkar_page.dart';
import 'package:siraty/features/azkar/presentation/pages/zekr_page.dart';
import 'package:siraty/features/home/presentation/pages/home_page.dart';
import 'package:siraty/features/prayer/presentation/pages/prayer_page.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/presentation/pages/quran_page.dart';
import 'package:siraty/features/quran/presentation/pages/surah_page.dart';
import 'package:siraty/features/splash/presentation/pages/splash_page.dart';
import 'package:siraty/features/tasbeeh/presentation/pages/tasbeeh_page.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/quran',
        builder: (context, state) => const QuranPage(),
      ),
      GoRoute(
        path: '/surah-details',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return SurahPage(
            surah: args['surah'] as SurahModel,
            surahName: args['surahName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/azkar',
        builder: (context, state) => const AzkarPage(),
      ),
      GoRoute(
        path: '/zekr-details',
        builder: (context, state) {
          final zekr = state.extra as AzkarModel;
          return ZekrPage(zekr: zekr);
        },
      ),
      GoRoute(
        path: '/tasbeeh',
        builder: (context, state) => const TasbeehPage(),
      ),
      GoRoute(
        path: '/prayer',
        builder: (context, state) => const PrayerPage(),
      ),
    ],
  );
}
