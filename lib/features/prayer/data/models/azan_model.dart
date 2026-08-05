import 'package:siraty/features/prayer/domain/entities/prayer_entity.dart';

class AzanModel extends PrayerTimingsEntity {
  const AzanModel({
    required super.azanTimes,
    required super.timesName,
  });

  factory AzanModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return AzanModel(
      azanTimes: [
        timings['Fajr'] ?? '',
        timings['Dhuhr'] ?? '',
        timings['Asr'] ?? '',
        timings['Maghrib'] ?? '',
        timings['Isha'] ?? '',
      ],
      timesName: const [
        'الفجر',
        'الظهر',
        'العصر',
        'المغرب',
        'العشاء',
      ],
    );
  }
}
