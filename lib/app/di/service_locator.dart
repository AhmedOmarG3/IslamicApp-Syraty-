import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/core/theme/theme_cubit.dart';
import 'package:siraty/features/azkar/data/datasource/azkar_local_data_source.dart';
import 'package:siraty/features/azkar/data/repositories/azkar_repository_impl.dart';
import 'package:siraty/features/azkar/domain/repositories/azkar_repository.dart';
import 'package:siraty/features/azkar/domain/usecases/get_azkar_usecase.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_cubit.dart';
import 'package:siraty/features/prayer/data/datasource/prayer_remote_data_source.dart';
import 'package:siraty/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:siraty/features/prayer/domain/usecases/get_prayer_timings_usecase.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/quran/data/datasource/quran_local_data_source.dart';
import 'package:siraty/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:siraty/features/quran/domain/repositories/quran_repository.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Services
  await LastReadService.loadLastRead();

  // Data Sources
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<PrayerRemoteDataSource>(
    () => PrayerRemoteDataSourceImpl(dio: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(remoteDataSource: getIt()),
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

  // Cubits
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sharedPreferences: getIt()),
  );
  getIt.registerFactory<QuranCubit>(
    () => QuranCubit(getSurahsUseCase: getIt(), sharedPreferences: getIt()),
  );
  getIt.registerFactory<AzkarCubit>(
    () => AzkarCubit(getAzkarUseCase: getIt()),
  );
  getIt.registerFactory<AzanCubit>(
    () => AzanCubit(getPrayerTimingsUseCase: getIt()),
  );
}
