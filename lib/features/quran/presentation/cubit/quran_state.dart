import 'package:equatable/equatable.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<SurahModel> surahs;
  final int? lastReadSurahIndex;

  const QuranLoaded({required this.surahs, this.lastReadSurahIndex});

  @override
  List<Object?> get props => [surahs, lastReadSurahIndex];
}

class QuranError extends QuranState {
  final String message;

  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}
