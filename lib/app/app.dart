import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/app/router/app_router.dart';
import 'package:siraty/core/theme/theme.dart';
import 'package:siraty/core/theme/theme_cubit.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_cubit.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';

class SiratyApp extends StatelessWidget {
  const SiratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 size reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ThemeCubit>()),
            BlocProvider(create: (_) => getIt<QuranCubit>()..loadQuran()),
            BlocProvider(create: (_) => getIt<AzkarCubit>()..loadAzkar()),
            BlocProvider(create: (_) => getIt<AzanCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: const Locale('ar'),
                builder: (context, child) {
                  final mediaQuery = MediaQuery.of(context);
                  return MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler: mediaQuery.textScaler.clamp(
                        minScaleFactor: 0.85,
                        maxScaleFactor: 1.25,
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
                routerConfig: AppRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
