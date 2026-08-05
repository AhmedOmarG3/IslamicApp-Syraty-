import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/domain/usecases/get_azkar_usecase.dart';
import 'package:siraty/features/azkar/presentation/cubit/azkar_state.dart';

class AzkarCubit extends Cubit<AzkarCubitState> {
  final GetAzkarUseCase getAzkarUseCase;

  AzkarCubit({required this.getAzkarUseCase}) : super(AzkarCubitInitial());

  Future<void> loadAzkar() async {
    emit(AzkarLoadingState());
    try {
      final azkarList = await getAzkarUseCase();
      emit(AzkarLoadedState(azkarList: azkarList.cast<AzkarModel>()));
    } catch (e) {
      emit(AzkarFailureState(errorMessage: e.toString()));
    }
  }
}
