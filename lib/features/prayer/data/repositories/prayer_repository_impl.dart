import 'package:siraty/features/prayer/data/datasource/prayer_remote_data_source.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_entity.dart';
import 'package:siraty/features/prayer/domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource remoteDataSource;

  PrayerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PrayerTimingsEntity?> getPrayerTimings({
    required String city,
    required String country,
  }) async {
    return await remoteDataSource.fetchAzanTimes(city: city, country: country);
  }
}
