import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/features/prayer/data/datasource/prayer_calculation_data_source.dart';
import 'package:siraty/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:siraty/features/prayer/domain/entities/calculation_method_setting.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_location.dart';

void main() {
  late PrayerRepositoryImpl repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = PrayerRepositoryImpl(
      calculationDataSource: const PrayerCalculationDataSourceImpl(),
      sharedPreferences: sharedPreferences,
    );
  });

  group('PrayerRepositoryImpl Tests', () {
    test('Default location is Cairo', () async {
      final loc = await repository.getSavedLocation();
      expect(loc.cityName, 'القاهرة');
      expect(loc.countryCode, 'EG');
    });

    test('Save location updates saved location and produces snapshot for that location', () async {
      const alexandria = PrayerLocation(
        cityName: 'الإسكندرية',
        countryName: 'مصر',
        countryCode: 'EG',
        latitude: 31.2001,
        longitude: 29.9187,
        timezone: 'Africa/Cairo',
      );

      await repository.saveLocation(alexandria);

      final saved = await repository.getSavedLocation();
      expect(saved.cityName, 'الإسكندرية');

      final snapshot = await repository.getPrayerSnapshot();
      expect(snapshot.location.cityName, 'الإسكندرية');
    });

    test('Save calculation method updates setting', () async {
      const customSetting = CalculationMethodSetting(
        method: CalculationMethod.karachi,
        asrMadhab: AsrMadhab.hanafi,
      );

      await repository.saveCalculationMethodSetting(customSetting);

      final loaded = await repository.getCalculationMethodSetting();
      expect(loaded.method, CalculationMethod.karachi);
      expect(loaded.asrMadhab, AsrMadhab.hanafi);
    });

    test('Reciter get and set defaults to Makkah and allows changes', () async {
      final defaultReciter = await repository.getSelectedReciter();
      expect(defaultReciter.id, 'makkah');

      await repository.setSelectedReciter('alafasy');
      final updated = await repository.getSelectedReciter();
      expect(updated.id, 'alafasy');
      expect(updated.displayName.contains('العفاسي'), isTrue);
    });

    test('Notifications toggle default is false and updates correctly', () async {
      expect(await repository.getNotificationsEnabled(), isFalse);

      await repository.setNotificationsEnabled(true);
      expect(await repository.getNotificationsEnabled(), isTrue);

      await repository.setNotificationsEnabled(false);
      expect(await repository.getNotificationsEnabled(), isFalse);
    });
  });
}
