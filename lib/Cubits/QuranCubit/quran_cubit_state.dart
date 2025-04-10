import 'package:siraty/Data/Models/surah_model.dart';

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<SurahModel> surahs;
  final int? lastReadSurahIndex;

  QuranLoaded({required this.surahs, this.lastReadSurahIndex});
}

class QuranError extends QuranState {
  final String message;

  QuranError(this.message);
}