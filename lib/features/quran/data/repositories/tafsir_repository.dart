import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/assets.dart';

class TafsirModel {
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String tafsirText;
  final String editionName;

  const TafsirModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.tafsirText,
    this.editionName = 'التفسير الميسر',
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'ayahText': ayahText,
        'tafsirText': tafsirText,
        'editionName': editionName,
      };

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      surahNumber: json['surahNumber'] as int? ?? 1,
      ayahNumber: json['ayahNumber'] as int? ?? 1,
      ayahText: json['ayahText'] as String? ?? '',
      tafsirText: json['tafsirText'] as String? ?? '',
      editionName:
          json['editionName'] as String? ?? 'التفسير الميسر',
    );
  }
}

/// 100% Offline Tafsir repository reading directly from the bundled
/// [AppAssets.tafsirJson] database containing all 114 surahs and 6236 ayahs.
/// No network calls, no internet permissions, no external dependencies.
class TafsirRepository {
  static final TafsirRepository instance = TafsirRepository._internal();
  TafsirRepository._internal() {
    _ensureOfflineLoaded();
  }

  final Map<String, TafsirModel> _memoryCache = {};
  Map<String, dynamic>? _offlineTafsirData;
  Future<void>? _initFuture;

  /// Ensures the bundled offline tafsir database (tafsir.json) is loaded.
  /// If already loading, all callers wait for the same future.
  Future<void> _ensureOfflineLoaded() {
    if (_offlineTafsirData != null) return Future.value();
    return _initFuture ??= _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    try {
      final jsonString = await rootBundle.loadString(AppAssets.tafsirJson);
      _offlineTafsirData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading offline tafsir.json: $e');
      _initFuture = null; // Allow retry if failed
    }
  }

  /// Fetch Tafsir for a specific Ayah directly from the bundled offline database.
  Future<TafsirModel?> getAyahTafsir({
    required int surahNum,
    required int ayahNum,
  }) async {
    final cacheKey = 'tafsir_${surahNum}_$ayahNum';

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    // 2. Read directly from the bundled offline database
    if (_offlineTafsirData == null) {
      await _ensureOfflineLoaded();
    }
    if (_offlineTafsirData != null) {
      final surahMap =
          _offlineTafsirData![surahNum.toString()] as Map<String, dynamic>?;
      final text = surahMap?[ayahNum.toString()] as String?;
      if (text != null && text.trim().isNotEmpty) {
        final model = TafsirModel(
          surahNumber: surahNum,
          ayahNumber: ayahNum,
          ayahText: '',
          tafsirText: text.trim(),
        );
        _memoryCache[cacheKey] = model;
        return model;
      }
    }

    return null;
  }
}
