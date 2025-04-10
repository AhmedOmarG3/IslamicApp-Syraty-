


import 'package:dio/dio.dart';
import 'package:siraty/Data/Models/azan_model.dart';

class AzanService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.aladhan.com/v1/timingsByCity';

  Future<AzanModel?> fetchAzanTimes({
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.get(
        baseUrl,
        queryParameters: {
          'city': city,
          'country': country,
        },
      );

      if (response.statusCode == 200) {
        return AzanModel.fromJson(response.data);
      } else {
        print('Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Request error: $e');
      return null;
    }
  }
}

