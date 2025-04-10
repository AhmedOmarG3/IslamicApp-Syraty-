import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:siraty/Data/Models/azan_model.dart';
import 'package:siraty/Data/Services/azan_service.dart';

part 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  AzanCubit() : super(AzanInitial());

  Future<void> loadAzan({required String city, required String country}) async {
    emit(AzanLoadingState());
    try {
      AzanModel? azanList =
          await AzanService().fetchAzanTimes(city: city, country: country);
      emit(AzanLoadedState(azanList: azanList!));
    } catch (e) {
      emit(
          AzanFailureState(errorMessage: "  حاول مرة اخرى\n فشل تحميل المواعيد"));
    }
  }
}
