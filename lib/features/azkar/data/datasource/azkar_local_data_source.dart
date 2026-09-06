import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';

abstract class AzkarLocalDataSource {
  Future<List<AzkarModel>> getAllAzkar();
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  List<AzkarModel>? _cachedAzkar;

  @override
  Future<List<AzkarModel>> getAllAzkar() async {
    if (_cachedAzkar != null) return _cachedAzkar!;
    final String jsonString = await rootBundle.loadString(AppAssets.adhkarJson);
    final List<dynamic> jsonResponse = json.decode(jsonString);
    _cachedAzkar = jsonResponse
        .map((item) => AzkarModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return _cachedAzkar!;
  }
}
