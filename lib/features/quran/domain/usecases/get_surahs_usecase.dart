import 'package:siraty/features/quran/domain/entities/surah_entity.dart';
import 'package:siraty/features/quran/domain/repositories/quran_repository.dart';

class GetSurahsUseCase {
  final QuranRepository repository;

  GetSurahsUseCase({required this.repository});

  Future<List<SurahEntity>> call() async {
    return await repository.getQuranSurahs();
  }
}
