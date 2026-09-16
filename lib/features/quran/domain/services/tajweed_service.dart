import 'dart:convert';
import 'package:flutter/services.dart';
import '../entities/tajweed_rule.dart';

class TajweedService {
  static List<TajweedCategory>? _cachedCategories;

  static Future<List<TajweedCategory>> loadTajweedCategories() async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/json/tajweed_rules.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final rawList = data['categories'] as List<dynamic>? ?? [];

      _cachedCategories = rawList
          .map((c) => TajweedCategory.fromJson(c as Map<String, dynamic>))
          .toList();

      return _cachedCategories!;
    } catch (_) {
      return [];
    }
  }

  static Future<List<TajweedRule>> getWaqfRules() async {
    final categories = await loadTajweedCategories();
    final waqfCategory = categories.firstWhere(
      (c) => c.id == 'waqf_rules',
      orElse: () => const TajweedCategory(
        id: '',
        title: '',
        icon: '',
        description: '',
        rules: [],
      ),
    );
    return waqfCategory.rules;
  }
}
