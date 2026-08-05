import 'package:siraty/features/quran/data/datasource/quran_local_data_source.dart';
import 'package:siraty/features/quran/domain/entities/surah_entity.dart';
import 'package:siraty/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource localDataSource;

  QuranRepositoryImpl({required this.localDataSource});

  @override
  Future<List<SurahEntity>> getQuranSurahs() async {
    return await localDataSource.loadQuranData();
  }
}
