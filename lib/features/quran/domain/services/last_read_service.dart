import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';

class LastReadModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final DateTime timestamp;

  const LastReadModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LastReadModel.fromJson(Map<String, dynamic> json) {
    return LastReadModel(
      surahNumber: json['surahNumber'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? 'الفاتحة',
      ayahNumber: json['ayahNumber'] as int? ?? 1,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class LastReadService {
  static const String _key = 'siraty_last_read_quran';
  static final ValueNotifier<LastReadModel?> lastReadNotifier =
      ValueNotifier<LastReadModel?>(null);

  /// Load initial last read from SharedPreferences
  static Future<LastReadModel?> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final model = LastReadModel.fromJson(map);
        lastReadNotifier.value = model;
        return model;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Save exact Ayah as the Last Read bookmark
  static Future<void> saveLastRead({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final model = LastReadModel(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: ayahNumber,
      timestamp: DateTime.now(),
    );
    await prefs.setString(_key, jsonEncode(model.toJson()));
    lastReadNotifier.value = model;
  }

  static Map<String, dynamic>? _cachedQuranJsonMap;

  /// Helper to load a SurahModel directly by its number with in-memory caching
  static Future<SurahModel?> loadSurah(int surahNumber) async {
    try {
      if (_cachedQuranJsonMap == null) {
        final String jsonString =
            await rootBundle.loadString(AppAssets.quranJson);
        _cachedQuranJsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      }
      final entry = _cachedQuranJsonMap![surahNumber.toString()];
      if (entry != null) {
        return SurahModel.fromJson(surahNumber, entry);
      }
    } catch (_) {}
    return null;
  }
}
