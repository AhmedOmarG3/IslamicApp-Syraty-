import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:siraty/Data/Models/azkar_model.dart';
import 'package:siraty/Data/Services/azkar_service.dart';

part 'azkar_cubit_state.dart';

class AzkarCubit extends Cubit<AzkarCubitState> {
  AzkarCubit() : super(AzkarCubitInitial());
   
   
Future<void> loadAzkar() async {
    emit(AzkarLoadingState());
    try {
      List<AzkarModel> azkarList = await AzkarService().getAllAzkar();
      emit(AzkarLoadedState(azkarList: azkarList));
      
    } catch (e) {
      emit(AzkarFailureState(errorMessage: e.toString()));
      
    }
  }


}
