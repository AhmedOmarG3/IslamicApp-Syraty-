import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';

abstract class AzkarLocalDataSource {
  Future<List<AzkarModel>> getAllAzkar();
}

class AzkarLocalDataSourceImpl implements AzkarLocalDataSource {
  @override
  Future<List<AzkarModel>> getAllAzkar() async {
    final String jsonString = await rootBundle.loadString(AppAssets.adhkarJson);
    List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((item) => AzkarModel.fromJson(item)).toList();
  }
}
