import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';

abstract class QuranLocalDataSource {
  Future<List<SurahModel>> loadQuranData();
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  @override
  Future<List<SurahModel>> loadQuranData() async {
    final String jsonString = await rootBundle.loadString(AppAssets.quranJson);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    List<SurahModel> allSurahs = jsonMap.entries.map((entry) {
      int surahNumber = int.parse(entry.key);
      return SurahModel.fromJson(surahNumber, entry.value);
    }).toList();

    return allSurahs;
  }
}
