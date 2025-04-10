import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:siraty/Data/Models/azkar_model.dart';

class AzkarService {
  Future<List<AzkarModel>> getAllAzkar() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/adhkar.json');
    List<dynamic> jsonResponse = json.decode(jsonString);

    // Convert the JSON response to a list of AzkarModel objects
    return jsonResponse.map((item) => AzkarModel.fromJson(item)).toList();
  }
}
