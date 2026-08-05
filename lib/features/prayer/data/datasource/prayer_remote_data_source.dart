import 'package:dio/dio.dart';
import 'package:siraty/core/constants/app_constants.dart';
import 'package:siraty/features/prayer/data/models/azan_model.dart';

abstract class PrayerRemoteDataSource {
  Future<AzanModel?> fetchAzanTimes({
    required String city,
    required String country,
  });
}

class PrayerRemoteDataSourceImpl implements PrayerRemoteDataSource {
  final Dio dio;

  PrayerRemoteDataSourceImpl({required this.dio});

  @override
  Future<AzanModel?> fetchAzanTimes({
    required String city,
    required String country,
  }) async {
    try {
      final response = await dio.get(
        AppConstants.azanBaseUrl,
        queryParameters: {
          'city': city,
          'country': country,
        },
      );

      if (response.statusCode == 200) {
        return AzanModel.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
