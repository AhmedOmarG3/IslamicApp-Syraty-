import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/Cubits/QuranCubit/quran_cubit_state.dart';
import 'package:siraty/Data/Models/surah_model.dart';
import 'package:siraty/Data/Services/quran_service.dart';


class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranInitial());

  List<SurahModel>? _cachedSurahs;

  Future<void> loadQuran() async {
    emit(QuranLoading());
    try {
      _cachedSurahs = await QuranService.loadQuranData();
      int? lastReadIndex = await _getLastReadIndex();
      emit(QuranLoaded(surahs: _cachedSurahs!, lastReadSurahIndex: lastReadIndex));
    } catch (e) {
      emit(QuranError("فشل تحميل السور"));
    }
  }

  Future<void> updateLastRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("last_read_index", index);

    if (state is QuranLoaded) {
      emit(QuranLoaded(
        surahs: (state as QuranLoaded).surahs,
        lastReadSurahIndex: index,
      ));
    }
  }

  Future<int?> _getLastReadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("last_read_index");
  }
}