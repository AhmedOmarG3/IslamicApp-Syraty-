import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/location_service.dart';
import '../../domain/entities/calculation_method_setting.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/usecases/get_next_prayer_usecase.dart';
import '../../domain/usecases/get_prayer_snapshot_usecase.dart';
import '../../domain/usecases/refresh_prayer_schedule_usecase.dart';
import '../../domain/usecases/set_prayer_location_usecase.dart';
import 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  final GetPrayerSnapshotUseCase getPrayerSnapshotUseCase;
  final GetNextPrayerUseCase getNextPrayerUseCase;
  final SetPrayerLocationUseCase setPrayerLocationUseCase;
  final RefreshPrayerScheduleUseCase refreshPrayerScheduleUseCase;
  final LocationService locationService;
  final PrayerRepository prayerRepository;

  Timer? _tickerTimer;

  AzanCubit({
    required this.getPrayerSnapshotUseCase,
    required this.getNextPrayerUseCase,
    required this.setPrayerLocationUseCase,
    required this.refreshPrayerScheduleUseCase,
    required this.locationService,
    required this.prayerRepository,
  }) : super(AzanInitial());

  Future<void> loadPrayerTimes({bool forceRecalculate = false}) async {
    emit(AzanLoadingState());
    try {
      final snapshot = await getPrayerSnapshotUseCase(forceRecalculate: forceRecalculate);
      final now = DateTime.now();
      final derivedToday = snapshot.today.withDerivedStatuses(now);
      final nextPrayerResult = await getNextPrayerUseCase(now);

      final countdown = nextPrayerResult?.prayer.time.difference(now);

      emit(AzanLoadedState(
        snapshot: snapshot,
        derivedToday: derivedToday,
        nextPrayer: nextPrayerResult,
        countdown: countdown,
      ));

      _startTicker();
      // Asynchronously refresh native alarms & widget
      refreshPrayerScheduleUseCase().catchError((_) {});
    } catch (e) {
      emit(const AzanFailureState(
        errorMessage: "تعذر تحميل مواقيت الصلاة، يرجى المحاولة مرة أخرى",
      ));
    }
  }

  /// Legacy support
  Future<void> loadAzan({required String city, required String country}) async {
    await loadPrayerTimes();
  }

  Future<bool> autoDetectLocation() async {
    try {
      final detected = await locationService.detectCurrentLocation();
      if (detected != null) {
        await setPrayerLocationUseCase(detected);
        await loadPrayerTimes(forceRecalculate: true);
        if (state is AzanLoadedState) {
          emit((state as AzanLoadedState).copyWith(isLocationAutoDetected: true));
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> changeLocation(PrayerLocation location) async {
    await setPrayerLocationUseCase(location);
    await loadPrayerTimes(forceRecalculate: true);
  }

  Future<void> changeCalculationMethod(CalculationMethodSetting setting) async {
    await prayerRepository.saveCalculationMethodSetting(setting);
    await loadPrayerTimes(forceRecalculate: true);
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed || state is! AzanLoadedState) return;

      final currentState = state as AzanLoadedState;
      final now = DateTime.now();

      // Check if next prayer time has arrived
      if (currentState.nextPrayer != null) {
        final remaining = currentState.nextPrayer!.prayer.time.difference(now);
        if (remaining.isNegative) {
          // Boundary crossed! Refresh statuses and find next prayer
          _refreshAfterBoundary();
          return;
        }

        emit(currentState.copyWith(countdown: remaining));
      }
    });
  }

  Future<void> _refreshAfterBoundary() async {
    final now = DateTime.now();
    final snapshot = await getPrayerSnapshotUseCase();
    final derivedToday = snapshot.today.withDerivedStatuses(now);
    final next = await getNextPrayerUseCase(now);
    final countdown = next?.prayer.time.difference(now);

    if (!isClosed && state is AzanLoadedState) {
      emit((state as AzanLoadedState).copyWith(
        snapshot: snapshot,
        derivedToday: derivedToday,
        nextPrayer: next,
        countdown: countdown,
      ));
    }
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    return super.close();
  }
}
