import 'package:siraty/features/quran/domain/entities/surah_entity.dart';

abstract class QuranRepository {
  Future<List<SurahEntity>> getQuranSurahs();
}
