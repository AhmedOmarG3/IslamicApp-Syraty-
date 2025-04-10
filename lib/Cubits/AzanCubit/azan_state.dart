part of 'azan_cubit.dart';

@immutable
sealed class AzanState {}

final class AzanInitial extends AzanState {}

final class AzanLoadingState extends AzanState {}

final class AzanLoadedState extends AzanState {
  final AzanModel azanList;

  AzanLoadedState({required this.azanList});
}

final class AzanFailureState extends AzanState {
  final String errorMessage;

  AzanFailureState({required this.errorMessage});
}
