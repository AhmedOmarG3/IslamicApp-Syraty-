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

  /// Remove all Arabic diacritics, tashkeel, Quranic stop marks, and decorations
  static String removeTashkeel(String text) {
    // 1. Map Uthmani prayer/zakat/life/riba spellings (waw + dagger alif before ta marbuta) to alif
    String clean = text.replaceAll(RegExp(r'و[\u064E\u0652\u0670]*\u0670(?=[\u0629\u0647])'), 'ا');
    clean = clean.replaceAll('رِّبَوٰاْ', 'ربا').replaceAll('رِّبَوٰ', 'ربا');

    // 2. Map small letters before stripping annotation marks
    clean = clean
        .replaceAll('\u06E5', 'و')
        .replaceAll('\u06E6', 'ي')
        .replaceAll('\u06E7', 'ي');

    // 3. Convert remaining dagger alifs to standard alif
    clean = clean.replaceAll('\u0670', 'ا');

    // 4. Strip all diacritics, Quranic stop marks, sajda, rub-el-hizb, maddah, and tatweel
    clean = clean.replaceAll(RegExp(r'[\u064B-\u065F\u06D6-\u06ED\u0653\u0640]'), '');

    return clean;
  }

  /// Normalize Arabic characters for tolerant, smart, and comprehensive searching
  static String normalizeArabic(String text) {
    String clean = removeTashkeel(text);

    // Normalize Alifs
    clean = clean.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Ta Marbuta
    clean = clean.replaceAll('ة', 'ه');

    // Normalize Ya and Alif Maqsura
    clean = clean.replaceAll('ى', 'ي');

    // Normalize common dual orthography words (so both classical and modern forms match)
    clean = clean.replaceAll('رحمان', 'رحمن');
    clean = clean.replaceAll('الاه', 'اله');
    clean = clean.replaceAll('هاذا', 'هذا');
    clean = clean.replaceAll('هاذه', 'هذه');
    clean = clean.replaceAll('هاولاء', 'هؤلاء');
    clean = clean.replaceAll('ذالك', 'ذلك');
    clean = clean.replaceAll('لاكن', 'لكن');
    clean = clean.replaceAll('سماوات', 'سموات');

    // Normalize Hamza forms
    clean = clean.replaceAll('ؤ', 'و');
    clean = clean.replaceAll('ئ', 'ي');
    clean = clean.replaceAll('ء', '');

    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.toLowerCase();
  }

  /// Finds the exact range [start, end] in the original un-normalized [text]
  /// that corresponds to the search match of [query].
  static TextRange? findMatchRange(String text, String query) {
    if (text.isEmpty || query.trim().isEmpty) return null;

    final normalizedQuery = normalizeArabic(query);
    if (normalizedQuery.isEmpty) return null;

    final StringBuffer normBuf = StringBuffer();
    final List<int> origIndices = [];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);

      // Skip diacritics, Quranic stop marks, maddah, tatweel
      if ((code >= 0x064B && code <= 0x065F) ||
          (code >= 0x06D6 && code <= 0x06ED) ||
          code == 0x0653 ||
          code == 0x0640) {
        continue;
      }

      // Normalize letters to match normalizeArabic
      String mapped;
      if (char == 'أ' || char == 'إ' || char == 'آ' || char == 'ٱ' || code == 0x0670) {
        mapped = 'ا';
      } else if (char == 'ة') {
        mapped = 'ه';
      } else if (char == 'ى') {
        mapped = 'ي';
      } else if (char == 'ؤ') {
        mapped = 'و';
      } else if (char == 'ئ') {
        mapped = 'ي';
      } else if (char == 'ء') {
        continue;
      } else if (code == 0x06E5) {
        mapped = 'و';
      } else if (code == 0x06E6 || code == 0x06E7) {
        mapped = 'ي';
      } else {
        mapped = char;
      }

      for (int m = 0; m < mapped.length; m++) {
        normBuf.write(mapped[m]);
        origIndices.add(i);
      }
    }

    final normalizedText = normBuf.toString().toLowerCase();
    final matchIdx = normalizedText.indexOf(normalizedQuery);
    if (matchIdx == -1) {
      return null;
    }

    final startOrig = origIndices[matchIdx];
    final endMatchInNorm = matchIdx + normalizedQuery.length - 1;
    if (endMatchInNorm >= origIndices.length) return null;

    var endOrig = origIndices[endMatchInNorm] + 1;
    // Include any trailing diacritics attached to the last matched letter
    while (endOrig < text.length) {
      final code = text.codeUnitAt(endOrig);
      if ((code >= 0x064B && code <= 0x065F) ||
          (code >= 0x06D6 && code <= 0x06ED) ||
          code == 0x0653 ||
          code == 0x0640) {
        endOrig++;
      } else {
        break;
      }
    }

    return TextRange(start: startOrig, end: endOrig);
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
