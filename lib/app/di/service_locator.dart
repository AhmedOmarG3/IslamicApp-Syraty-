import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/core/theme/theme_cubit.dart';
import 'package:siraty/features/azkar/data/datasource/azkar_local_data_source.dart';
import 'package:siraty/features/azkar/data/repositories/azkar_repository_impl.dart';
import 'package:siraty/features/azkar/domain/repositories/azkar_repository.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_cubit.dart';
import 'package:siraty/features/azkar/domain/usecases/get_azkar_usecase.dart';
import 'package:siraty/core/services/haptic_service.dart';
import 'package:siraty/core/services/native_prayer_scheduler.dart';
import 'package:siraty/core/services/prayer_scheduler_interface.dart';
import 'package:siraty/features/prayer/data/datasource/city_database_data_source.dart';
import 'package:siraty/features/prayer/data/datasource/prayer_calculation_data_source.dart';
import 'package:siraty/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:siraty/features/prayer/data/services/location_service.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:siraty/features/prayer/domain/usecases/get_next_prayer_usecase.dart';
import 'package:siraty/features/prayer/domain/usecases/get_prayer_snapshot_usecase.dart';
import 'package:siraty/features/prayer/domain/usecases/get_prayer_timings_usecase.dart';
import 'package:siraty/features/prayer/domain/usecases/refresh_prayer_schedule_usecase.dart';
import 'package:siraty/features/prayer/domain/usecases/set_prayer_location_usecase.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/quran/data/datasource/quran_local_data_source.dart';
import 'package:siraty/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';
import 'package:siraty/features/quran/domain/repositories/quran_repository.dart';
import 'package:siraty/features/quran/domain/services/khatma_service.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:siraty/features/quran/presentation/cubit/mushaf_settings_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_download_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Services
  await LastReadService.loadLastRead();
  await KhatmaService.init(sharedPreferences);
  getIt.registerSingleton<HapticService>(HapticService(sharedPreferences));

  // Data Sources
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PrayerCalculationDataSource>(
    () => const PrayerCalculationDataSourceImpl(),
  );
  getIt.registerLazySingleton<CityDatabaseDataSource>(
    () => CityDatabaseDataSourceImpl(),
  );

  // Services
  getIt.registerLazySingleton<LocationService>(
    () => LocationServiceImpl(cityDatabase: getIt()),
  );
  getIt.registerLazySingleton<PrayerSchedulerInterface>(
    () => const NativePrayerScheduler(),
  );
  // Quran Download Service & Audio
  final quranDownloadService = QuranDownloadService(dio: getIt<Dio>());
  await quranDownloadService.init();
  getIt.registerSingleton<QuranDownloadService>(quranDownloadService);

  getIt.registerLazySingleton<QuranAudioService>(
    () => QuranAudioService(downloadService: getIt<QuranDownloadService>()),
  );

  // Repositories
  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(
      calculationDataSource: getIt(),
      sharedPreferences: getIt(),
    ),
  );

  // UseCases
  getIt.registerLazySingleton<GetSurahsUseCase>(
    () => GetSurahsUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetAzkarUseCase>(
    () => GetAzkarUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetPrayerTimingsUseCase>(
    () => GetPrayerTimingsUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetPrayerSnapshotUseCase>(
    () => GetPrayerSnapshotUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<GetNextPrayerUseCase>(
    () => GetNextPrayerUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<SetPrayerLocationUseCase>(
    () => SetPrayerLocationUseCase(repository: getIt()),
  );
  getIt.registerLazySingleton<RefreshPrayerScheduleUseCase>(
    () => RefreshPrayerScheduleUseCase(
      repository: getIt(),
      scheduler: getIt(),
    ),
  );

  // Cubits
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sharedPreferences: getIt()),
  );
  // Audio playback is app-global state (mini player survives navigation)
  getIt.registerLazySingleton<QuranAudioCubit>(
    () => QuranAudioCubit(service: getIt()),
  );
  // Quran audio download manager & offline cache tracking
  getIt.registerLazySingleton<QuranDownloadCubit>(
    () => QuranDownloadCubit(downloadService: getIt<QuranDownloadService>()),
  );
  // Mushaf reading preferences (font size, paper theme) — persisted
  getIt.registerLazySingleton<MushafSettingsCubit>(
    () => MushafSettingsCubit(prefs: getIt<SharedPreferences>()),
  );
  getIt.registerFactory<QuranCubit>(
    () => QuranCubit(getSurahsUseCase: getIt(), sharedPreferences: getIt()),
  );
  getIt.registerFactory<AzkarCubit>(
    () => AzkarCubit(getAzkarUseCase: getIt()),
  );
  getIt.registerFactory<AzanCubit>(
    () => AzanCubit(
      getPrayerSnapshotUseCase: getIt(),
      getNextPrayerUseCase: getIt(),
      setPrayerLocationUseCase: getIt(),
      refreshPrayerScheduleUseCase: getIt(),
      locationService: getIt(),
      prayerRepository: getIt(),
    ),
  );
}
