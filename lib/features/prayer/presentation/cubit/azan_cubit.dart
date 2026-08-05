import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/features/prayer/data/models/azan_model.dart';
import 'package:siraty/features/prayer/domain/usecases/get_prayer_timings_usecase.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  final GetPrayerTimingsUseCase getPrayerTimingsUseCase;

  AzanCubit({required this.getPrayerTimingsUseCase}) : super(AzanInitial());

  Future<void> loadAzan({required String city, required String country}) async {
    emit(AzanLoadingState());
    try {
      final azan =
          await getPrayerTimingsUseCase(city: city, country: country);
      if (azan != null) {
        emit(AzanLoadedState(azanList: azan as AzanModel));
      } else {
        emit(const AzanFailureState(
            errorMessage: "حاول مرة اخرى\nفشل تحميل المواعيد"));
      }
    } catch (_) {
      emit(const AzanFailureState(
          errorMessage: "حاول مرة اخرى\nفشل تحميل المواعيد"));
    }
  }
}
