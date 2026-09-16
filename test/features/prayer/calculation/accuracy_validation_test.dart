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

  group('T021: Accuracy Validation Matrix Across Regions and Seasons', () {
    const egyptCities = [
      PrayerLocation(
        cityName: 'القاهرة',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 30.0444,
        longitude: 31.2357,
        timezone: 'Africa/Cairo',
      ),
      PrayerLocation(
        cityName: 'الإسكندرية',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 31.2001,
        longitude: 29.9187,
        timezone: 'Africa/Cairo',
      ),
      PrayerLocation(
        cityName: 'أسوان',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 24.0889,
        longitude: 32.8998,
        timezone: 'Africa/Cairo',
      ),
      PrayerLocation(
        cityName: 'بورسعيد',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 31.2653,
        longitude: 32.3019,
        timezone: 'Africa/Cairo',
      ),
      PrayerLocation(
        cityName: 'أسيوط',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 27.1783,
        longitude: 31.1859,
        timezone: 'Africa/Cairo',
      ),
    ];

    const ksaCities = [
      PrayerLocation(
        cityName: 'مكة المكرمة',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 21.4225,
        longitude: 39.8262,
        timezone: 'Asia/Riyadh',
      ),
      PrayerLocation(
        cityName: 'المدينة المنورة',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 24.5247,
        longitude: 39.5692,
        timezone: 'Asia/Riyadh',
      ),
      PrayerLocation(
        cityName: 'الرياض',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 24.7136,
        longitude: 46.6753,
        timezone: 'Asia/Riyadh',
      ),
      PrayerLocation(
        cityName: 'جدة',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 21.5433,
        longitude: 39.1728,
        timezone: 'Asia/Riyadh',
      ),
      PrayerLocation(
        cityName: 'الدمام',
        countryName: 'المملكة العربية السعودية',
        countryCode: 'SA',
        latitude: 26.4207,
        longitude: 50.0888,
        timezone: 'Asia/Riyadh',
      ),
    ];

    final seasonalDates = [
      DateTime(2026, 3, 21), // Spring equinox
      DateTime(2026, 6, 21), // Summer solstice
      DateTime(2026, 9, 21), // Autumn equinox
      DateTime(2026, 12, 21), // Winter solstice
    ];

    test('Egypt Matrix: All 5 cities × 4 seasonal dates adhere strictly to chronological order', () {
      const setting = CalculationMethodSetting(method: CalculationMethod.auto);

      for (final city in egyptCities) {
        for (final date in seasonalDates) {
          final day = dataSource.calculatePrayerDay(
            location: city,
            setting: setting,
            date: date,
          );

          expect(day.times.length, 6);
          final fajr = day.getTime(PrayerType.fajr)!.time;
          final sunrise = day.getTime(PrayerType.sunrise)!.time;
          final dhuhr = day.getTime(PrayerType.dhuhr)!.time;
          final asr = day.getTime(PrayerType.asr)!.time;
          final maghrib = day.getTime(PrayerType.maghrib)!.time;
          final isha = day.getTime(PrayerType.isha)!.time;

          expect(fajr.isBefore(sunrise), isTrue, reason: 'Fajr < Sunrise for ${city.cityName} on $date');
          expect(sunrise.isBefore(dhuhr), isTrue, reason: 'Sunrise < Dhuhr for ${city.cityName} on $date');
          expect(dhuhr.isBefore(asr), isTrue, reason: 'Dhuhr < Asr for ${city.cityName} on $date');
          expect(asr.isBefore(maghrib), isTrue, reason: 'Asr < Maghrib for ${city.cityName} on $date');
          expect(maghrib.isBefore(isha), isTrue, reason: 'Maghrib < Isha for ${city.cityName} on $date');
        }
      }
    });

    test('KSA Matrix: All 5 cities × 4 seasonal dates adhere strictly to chronological order and 90min Isha interval', () {
      const setting = CalculationMethodSetting(method: CalculationMethod.auto);

      for (final city in ksaCities) {
        for (final date in seasonalDates) {
          final day = dataSource.calculatePrayerDay(
            location: city,
            setting: setting,
            date: date,
          );

          expect(day.times.length, 6);
          final fajr = day.getTime(PrayerType.fajr)!.time;
          final sunrise = day.getTime(PrayerType.sunrise)!.time;
          final dhuhr = day.getTime(PrayerType.dhuhr)!.time;
          final asr = day.getTime(PrayerType.asr)!.time;
          final maghrib = day.getTime(PrayerType.maghrib)!.time;
          final isha = day.getTime(PrayerType.isha)!.time;

          expect(fajr.isBefore(sunrise), isTrue);
          expect(sunrise.isBefore(dhuhr), isTrue);
          expect(dhuhr.isBefore(asr), isTrue);
          expect(asr.isBefore(maghrib), isTrue);
          expect(maghrib.isBefore(isha), isTrue);

          // In Umm Al-Qura, Isha is exactly 90 minutes after Maghrib
          final interval = isha.difference(maghrib).inMinutes;
          expect(interval, 90, reason: 'Umm Al-Qura 90m interval in ${city.cityName} on $date');
        }
      }
    });
  });
}
