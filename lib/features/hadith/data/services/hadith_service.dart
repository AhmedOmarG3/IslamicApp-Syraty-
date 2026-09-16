import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

class HadithChapterInfo {
  final int id;
  final String name;
  final int count;

  const HadithChapterInfo({
    required this.id,
    required this.name,
    required this.count,
  });
}

class HadithService {
  static List<HadithModel>? _cachedSelected;
  static List<HadithModel>? _cachedBukhari;
  static List<HadithModel>? _cachedMuslim;

  /// Loads curated / selected hadiths from offline assets/json/hadith.json
  static Future<List<HadithModel>> getAllHadiths() async {
    return loadBook('selected');
  }

  /// Loads hadiths for the requested book key ('selected', 'bukhari', 'muslim')
  static Future<List<HadithModel>> loadBook(String bookKey) async {
    switch (bookKey) {
      case 'bukhari':
        if (_cachedBukhari != null && _cachedBukhari!.isNotEmpty) {
          return _cachedBukhari!;
        }
        _cachedBukhari = await _loadJsonAsset('assets/json/bukhari.json');
        return _cachedBukhari!;

      case 'muslim':
        if (_cachedMuslim != null && _cachedMuslim!.isNotEmpty) {
          return _cachedMuslim!;
        }
        _cachedMuslim = await _loadJsonAsset('assets/json/muslim.json');
        return _cachedMuslim!;

      case 'selected':
      default:
        if (_cachedSelected != null && _cachedSelected!.isNotEmpty) {
          return _cachedSelected!;
        }
        _cachedSelected = await _loadJsonAsset('assets/json/hadith.json');
        return _cachedSelected!;
    }
  }

  static Future<List<HadithModel>> _loadJsonAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      // Run heavy JSON parsing in a background isolate to keep UI 60/120fps
      return await compute(_parseHadithsJson, jsonString);
    } catch (e, stack) {
      debugPrint('Error loading hadith asset $assetPath: $e\n$stack');
      return [];
    }
  }

  static List<HadithModel> parseHadithsJsonString(String jsonString) {
    return _parseHadithsJson(jsonString);
  }


  static List<HadithModel> _parseHadithsJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => HadithModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Normalizes Arabic text for accurate, diacritics-insensitive searching.
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';
    var s = text.toLowerCase();

    // 1. Strip diacritics / tashkeel
    s = s.replaceAll(RegExp(r'[\u064B-\u0655\u0670\u0640]'), '');

    // 2. Normalize Alef variants (أ, إ, آ, ٱ) -> ا
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 3. Normalize Taa Marbuta (ة) -> ه
    s = s.replaceAll('ة', 'ه');

    // 4. Normalize Alef Maqsura (ى) -> ي
    s = s.replaceAll('ى', 'ي');

    // 5. Replace punctuation and brackets with space
    s = s.replaceAll(RegExp(r'[«»"“”\x27\x22،,\.\-–—\(\)\[\]\{\}؛:!؟\?/\\]'), ' ');

    // 6. Normalize multiple whitespaces
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts Arabic numbers (١٢٣) to Latin digits (123)
  static String convertArabicDigitsToLatin(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], i.toString());
    }
    return result;
  }

  /// Extracts unique chapter names in appearance order, including 'الكل'
  static List<String> getChapters(List<HadithModel> hadiths) {
    final chapters = <String>{'الكل'};
    for (final h in hadiths) {
      final ch = h.chapter.trim();
      if (ch.isNotEmpty) {
        chapters.add(ch);
      }
    }
    return chapters.toList();
  }

  /// Extracts unique chapters with their hadith counts in appearance order
  static List<HadithChapterInfo> getChaptersWithCounts(List<HadithModel> hadiths) {
    final Map<String, int> counts = {};
    for (final h in hadiths) {
      final ch = h.chapter.trim().isNotEmpty ? h.chapter.trim() : h.category.trim();
      if (ch.isNotEmpty) {
        counts[ch] = (counts[ch] ?? 0) + 1;
      }
    }
    int index = 1;
    return counts.entries.map((e) {
      return HadithChapterInfo(
        id: index++,
        name: e.key,
        count: e.value,
      );
    }).toList();
  }

  /// Extracts unique category names including 'الكل' (backward compatible)
  static List<String> getCategories(List<HadithModel> hadiths) {
    final categories = <String>{'الكل'};
    for (final h in hadiths) {
      if (h.category.trim().isNotEmpty) {
        categories.add(h.category.trim());
      }
    }
    return categories.toList();
  }

  /// Returns count of hadiths per category
  static Map<String, int> getCategoryCounts(List<HadithModel> hadiths) {
    final counts = <String, int>{'الكل': hadiths.length};
    for (final h in hadiths) {
      final cat = h.category.trim();
      if (cat.isNotEmpty) {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Extracts unique book sources including 'الكل'
  static List<String> getBooks(List<HadithModel> hadiths) {
    final books = <String>{'الكل'};
    for (final h in hadiths) {
      if (h.book.trim().isNotEmpty) {
        books.add(h.book.trim());
      }
    }
    return books.toList();
  }

  /// Searches hadiths using normalized multi-token Arabic matching across
  /// title, text, narrator, source, explanation, category, and hadith number.
  static List<HadithModel> searchHadiths(List<HadithModel> hadiths, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return hadiths;

    // Direct number search support (e.g. searching "1" or "١")
    final latinDigits = convertArabicDigitsToLatin(trimmedQuery);
    final targetId = int.tryParse(latinDigits);

    final normalizedQuery = normalizeArabic(trimmedQuery);
    final tokens = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();

    return hadiths.where((h) {
      if (targetId != null && h.id == targetId) {
        return true;
      }

      if (tokens.isEmpty) return true;

      final combined = normalizeArabic(
        '${h.title} ${h.arabic} ${h.narrator} ${h.source} ${h.chapter} ${h.explanation} ${h.category}',
      );
      // Every search token must match in the combined text
      return tokens.every((token) => combined.contains(token));
    }).toList();
  }

  /// Filters hadiths by book, chapter/category
  static List<HadithModel> filterHadiths({
    required List<HadithModel> hadiths,
    String selectedBook = 'الكل',
    String selectedCategory = 'الكل',
  }) {
    var result = hadiths;
    if (selectedBook != 'الكل' && selectedBook.trim().isNotEmpty) {
      result = result.where((h) => h.book.trim() == selectedBook.trim()).toList();
    }
    if (selectedCategory != 'الكل' && selectedCategory.trim().isNotEmpty) {
      result = result.where((h) =>
          h.chapter.trim() == selectedCategory.trim() ||
          h.category.trim() == selectedCategory.trim()).toList();
    }
    return result;
  }

  /// Filters hadiths by category (for backward compatibility)
  static List<HadithModel> filterByCategory(List<HadithModel> hadiths, String category) {
    if (category == 'الكل' || category.trim().isEmpty) return hadiths;
    return hadiths.where((h) =>
        h.chapter.trim() == category.trim() ||
        h.category.trim() == category.trim()).toList();
  }
}

