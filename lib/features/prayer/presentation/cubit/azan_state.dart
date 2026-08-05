import 'package:equatable/equatable.dart';
import 'package:siraty/features/prayer/data/models/azan_model.dart';

abstract class AzanState extends Equatable {
  const AzanState();

  @override
  List<Object?> get props => [];
}

class AzanInitial extends AzanState {}

class AzanLoadingState extends AzanState {}

class AzanLoadedState extends AzanState {
  final AzanModel azanList;

  const AzanLoadedState({required this.azanList});

  @override
  List<Object?> get props => [azanList];
}

class AzanFailureState extends AzanState {
  final String errorMessage;

  const AzanFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
