part of 'azkar_cubit.dart';

@immutable
sealed class AzkarCubitState {}

final class AzkarCubitInitial extends AzkarCubitState {}
final class AzkarLoadingState extends AzkarCubitState {}
final class AzkarLoadedState extends AzkarCubitState {
AzkarLoadedState({
  required this.azkarList,
});
final List<AzkarModel> azkarList;

}
final class AzkarFailureState extends AzkarCubitState {
  AzkarFailureState({
    this.errorMessage = "فشل تحميل الأذكار",
  });
  final String errorMessage;
}