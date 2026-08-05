import 'package:equatable/equatable.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';

abstract class AzkarCubitState extends Equatable {
  const AzkarCubitState();

  @override
  List<Object?> get props => [];
}

class AzkarCubitInitial extends AzkarCubitState {}

class AzkarLoadingState extends AzkarCubitState {}

class AzkarLoadedState extends AzkarCubitState {
  final List<AzkarModel> azkarList;

  const AzkarLoadedState({required this.azkarList});

  @override
  List<Object?> get props => [azkarList];
}

class AzkarFailureState extends AzkarCubitState {
  final String errorMessage;

  const AzkarFailureState({this.errorMessage = "فشل تحميل الأذكار"});

  @override
  List<Object?> get props => [errorMessage];
}
