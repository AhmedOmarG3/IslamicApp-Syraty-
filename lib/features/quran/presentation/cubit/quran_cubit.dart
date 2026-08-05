import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/core/constants/app_constants.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  final GetSurahsUseCase getSurahsUseCase;
  final SharedPreferences sharedPreferences;

  QuranCubit({
    required this.getSurahsUseCase,
    required this.sharedPreferences,
  }) : super(QuranInitial());

  List<SurahModel>? _cachedSurahs;

  Future<void> loadQuran() async {
    emit(QuranLoading());
    try {
      final surahs = await getSurahsUseCase();
      _cachedSurahs = surahs.cast<SurahModel>();
      int? lastReadIndex = sharedPreferences.getInt(AppConstants.lastReadIndexKey);
      emit(QuranLoaded(
        surahs: _cachedSurahs!,
        lastReadSurahIndex: lastReadIndex,
      ));
    } catch (_) {
      emit(const QuranError("فشل تحميل السور"));
    }
  }

  Future<void> updateLastRead(int index) async {
    await sharedPreferences.setInt(AppConstants.lastReadIndexKey, index);

    if (state is QuranLoaded) {
      emit(QuranLoaded(
        surahs: (state as QuranLoaded).surahs,
        lastReadSurahIndex: index,
      ));
    }
  }
}
