import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siraty/Data/Models/surah_model.dart';


class QuranService {
  static Future<List<SurahModel>> loadQuranData() async {
    final String jsonString = await rootBundle.loadString('assets/json/quran.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    List<SurahModel> allSurahs = jsonMap.entries.map((entry) {
      int surahNumber = int.parse(entry.key);
      return SurahModel.fromJson(surahNumber, entry.value);
    }).toList();

    return allSurahs;
  }
}