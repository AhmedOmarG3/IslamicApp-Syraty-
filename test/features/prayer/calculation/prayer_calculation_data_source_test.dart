import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/prayer/data/datasource/prayer_calculation_data_source.dart';
import 'package:siraty/features/prayer/domain/entities/calculation_method_setting.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_location.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_time.dart';

void main() {
  late PrayerCalculationDataSource dataSource;

  setUp(() {
    dataSource = const PrayerCalculationDataSourceImpl();
  });

  group('PrayerCalculationDataSource Tests', () {
    test('Egyptian calculation parameters adhere to fajr < sunrise < dhuhr < asr < maghrib < isha', () {
      const location = PrayerLocation(
        cityName: 'القاهرة',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 'Africa/Cairo',
      );

      const setting = CalculationMethodSetting(
        method: CalculationMethod.auto,
        asrMadhab: AsrMadhab.shafi,
      );

      final date = DateTime(2026, 9, 7);
      final prayerDay = dataSource.calculatePrayerDay(
        location: location,
        setting: setting,
        date: date,
      );

      expect(prayerDay.times.length, 6);
      final fajr = prayerDay.getTime(PrayerType.fajr)!.time;
      final sunrise = prayerDay.getTime(PrayerType.sunrise)!.time;
      final dhuhr = prayerDay.getTime(PrayerType.dhuhr)!.time;
      final asr = prayerDay.getTime(PrayerType.asr)!.time;
      final maghrib = prayerDay.getTime(PrayerType.maghrib)!.time;
      final isha = prayerDay.getTime(PrayerType.isha)!.time;

      expect(fajr.isBefore(sunrise), isTrue);
      expect(sunrise.isBefore(dhuhr), isTrue);
      expect(dhuhr.isBefore(asr), isTrue);
      expect(asr.isBefore(maghrib), isTrue);
      expect(maghrib.isBefore(isha), isTrue);
    });

    test('Saudi Arabia (Makkah) auto-selects Umm Al-Qura with 90min Isha interval', () {
      const location = PrayerLocation(
        cityName: 'مكة المكرمة',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 21.4225,
        longitude: 39.8262,
        timezone: 'Asia/Riyadh',
      );

      const setting = CalculationMethodSetting(
        method: CalculationMethod.auto,
      );

      final date = DateTime(2026, 9, 7);
      final prayerDay = dataSource.calculatePrayerDay(
        location: location,
        setting: setting,
        date: date,
      );

      final maghrib = prayerDay.getTime(PrayerType.maghrib)!.time;
      final isha = prayerDay.getTime(PrayerType.isha)!.time;

      // Umm Al-Qura has a 90-minute interval between Maghrib and Isha (except Ramadan)
      final diffMinutes = isha.difference(maghrib).inMinutes;
      expect(diffMinutes, 90);
    });

    test('Hanafi Asr madhab produces later Asr time than Shafi', () {
      const location = PrayerLocation(
        cityName: 'القاهرة',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 'Africa/Cairo',
      );

      final date = DateTime(2026, 9, 7);

      final shafiDay = dataSource.calculatePrayerDay(
        location: location,
        setting: const CalculationMethodSetting(
          method: CalculationMethod.egyptian,
          asrMadhab: AsrMadhab.shafi,
        ),
        date: date,
      );

      final hanafiDay = dataSource.calculatePrayerDay(
        location: location,
        setting: const CalculationMethodSetting(
          method: CalculationMethod.egyptian,
          asrMadhab: AsrMadhab.hanafi,
        ),
        date: date,
      );

      final shafiAsr = shafiDay.getTime(PrayerType.asr)!.time;
      final hanafiAsr = hanafiDay.getTime(PrayerType.asr)!.time;

      expect(hanafiAsr.isAfter(shafiAsr), isTrue);
    });
  });
}
