import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.editionName = 'التفسير الميسر (مجمع الملك فهد)',
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
      editionName: json['editionName'] as String? ?? 'التفسير الميسر (مجمع الملك فهد)',
    );
  }
}

class TafsirRepository {
  static final TafsirRepository instance = TafsirRepository._internal();
  TafsirRepository._internal();

  final Dio _dio = Dio();
  final Map<String, TafsirModel> _memoryCache = {};

  /// Fetch Tafsir for a specific Ayah (with local offline cache)
  Future<TafsirModel?> getAyahTafsir({
    required int surahNum,
    required int ayahNum,
  }) async {
    final cacheKey = 'tafsir_${surahNum}_$ayahNum';

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    // 2. Check persistent SharedPreferences cache (Offline storage)
    final prefs = await SharedPreferences.getInstance();
    final cachedRaw = prefs.getString(cacheKey);
    if (cachedRaw != null) {
      try {
        final model = TafsirModel.fromJson(jsonDecode(cachedRaw));
        _memoryCache[cacheKey] = model;
        return model;
      } catch (_) {}
    }

    // 3. Fetch from AlQuran Cloud API (Tafsir Al-Muyassar)
    try {
      final url = 'https://api.alquran.cloud/v1/ayah/$surahNum:$ayahNum/ar.muyassar';
      final response = await _dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final tafsirText = data['text'] as String? ?? '';
        final model = TafsirModel(
          surahNumber: surahNum,
          ayahNumber: ayahNum,
          ayahText: '',
          tafsirText: tafsirText,
        );

        // Save in persistent offline cache
        await prefs.setString(cacheKey, jsonEncode(model.toJson()));
        _memoryCache[cacheKey] = model;
        return model;
      }
    } catch (e) {
      debugPrint('Tafsir fetch error: $e');
    }

    return null;
  }
}
