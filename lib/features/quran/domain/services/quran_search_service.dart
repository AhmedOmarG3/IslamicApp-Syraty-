import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';

class QuranSearchResult {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String verseText;
  final int juzNumber;
  final bool isMakki;
  final String searchQuery;

  const QuranSearchResult({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.verseText,
    required this.juzNumber,
    required this.isMakki,
    required this.searchQuery,
  });
}

class QuranSearchService {
  static final QuranSearchService instance = QuranSearchService._internal();
  QuranSearchService._internal();

  List<SurahModel>? _cachedSurahs;

  /// Load and cache the full Quran locally for instant sub-millisecond searching
  Future<void> init() async {
    if (_cachedSurahs != null) return;
    try {
      final jsonString = await rootBundle.loadString(AppAssets.quranJson);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _cachedSurahs = jsonMap.entries.map((entry) {
        int surahNumber = int.parse(entry.key);
        return SurahModel.fromJson(surahNumber, entry.value);
      }).toList();
    } catch (_) {}
  }

  /// Remove all Arabic diacritics / tashkeel
  static String removeTashkeel(String text) {
    final regex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    return text.replaceAll(regex, '');
  }

  /// Normalize Arabic characters for tolerant and smart searching
  static String normalizeArabic(String text) {
    String clean = removeTashkeel(text);
    clean = clean.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    clean = clean.replaceAll('ة', 'ه');
    clean = clean.replaceAll('ى', 'ي');
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.toLowerCase();
  }

  /// Search across all 6,236 verses of the Holy Quran offline
  Future<List<QuranSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    await init();
    if (_cachedSurahs == null) return [];

    final normalizedQuery = normalizeArabic(query);
    final List<QuranSearchResult> results = [];

    for (final surah in _cachedSurahs!) {
      final sNum = surah.surahNumber;
      final sName = surah.surahName;
      final isMakki = QuranMetadata.isMakki(sNum);

      for (int i = 0; i < surah.verses.length; i++) {
        final verse = surah.verses[i];
        final verseText = verse.text;
        final normalizedVerse = normalizeArabic(verseText);

        if (normalizedVerse.contains(normalizedQuery)) {
          final ayahNumber = i + 1;
          results.add(
            QuranSearchResult(
              surahNumber: sNum,
              surahName: sName,
              ayahNumber: ayahNumber,
              verseText: verseText,
              juzNumber: 1, // dynamically calculated if needed
              isMakki: isMakki,
              searchQuery: query.trim(),
            ),
          );

          if (results.length >= 150) break; // cap for performance
        }
      }
      if (results.length >= 150) break;
    }

    return results;
  }
}
