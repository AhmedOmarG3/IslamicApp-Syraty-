import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class TafsirRepository {
  static final TafsirRepository instance = TafsirRepository._internal();
  TafsirRepository._internal() {
    _initOfflineTafsir();
  }

  final Dio _dio = Dio();
  final Map<String, TafsirModel> _memoryCache = {};
  Map<String, dynamic>? _offlineTafsirData;
  bool _isLoadingOffline = false;

  Future<void> _initOfflineTafsir() async {
    if (_offlineTafsirData != null || _isLoadingOffline) return;
    _isLoadingOffline = true;
    try {
      final jsonString = await rootBundle.loadString(AppAssets.tafsirJson);
      _offlineTafsirData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading offline tafsir.json: $e');
    } finally {
      _isLoadingOffline = false;
    }
  }

  /// Fetch Tafsir for a specific Ayah (Instant Offline first, with API fallback)
  Future<TafsirModel?> getAyahTafsir({
    required int surahNum,
    required int ayahNum,
  }) async {
    final cacheKey = 'tafsir_${surahNum}_$ayahNum';

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey];
    }

    // 2. Check complete bundled offline JSON database (100% Offline)
    if (_offlineTafsirData == null) {
      await _initOfflineTafsir();
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

    // 3. Check persistent SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final cachedRaw = prefs.getString(cacheKey);
    if (cachedRaw != null) {
      try {
        final model = TafsirModel.fromJson(jsonDecode(cachedRaw));
        _memoryCache[cacheKey] = model;
        return model;
      } catch (_) {}
    }

    // 4. Fallback: Fetch from AlQuran Cloud API (if offline not found)
    try {
      final url =
          'https://api.alquran.cloud/v1/ayah/$surahNum:$ayahNum/ar.muyassar';
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
