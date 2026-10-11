import 'package:adhan_dart/adhan_dart.dart' as adhan;
import '../../domain/entities/calculation_method_setting.dart';
import '../../domain/entities/prayer_day.dart';
import '../../domain/entities/prayer_location.dart';
import '../../domain/entities/prayer_time.dart';

abstract class PrayerCalculationDataSource {
  PrayerDay calculatePrayerDay({
    required PrayerLocation location,
    required CalculationMethodSetting setting,
    required DateTime date,
  });
}

class PrayerCalculationDataSourceImpl implements PrayerCalculationDataSource {
  const PrayerCalculationDataSourceImpl();

  @override
  PrayerDay calculatePrayerDay({
    required PrayerLocation location,
    required CalculationMethodSetting setting,
    required DateTime date,
  }) {
    final params = _resolveParameters(setting, location.countryCode);

    // Apply Asr madhab
    params.madhab = setting.asrMadhab == AsrMadhab.hanafi
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;

    final coordinates = adhan.Coordinates(location.latitude, location.longitude);
    
    // Normalize date to calendar year/month/day
    final calcDate = DateTime(date.year, date.month, date.day);

    final pt = adhan.PrayerTimes(
      coordinates: coordinates,
      date: calcDate,
      calculationParameters: params,
      precision: true,
    );

    // Note: adhan_dart returns UTC DateTime instances. Convert them to local DateTime.
    final dstOffset = setting.daylightSaving ? const Duration(hours: 1) : Duration.zero;

    final times = <PrayerTime>[
      PrayerTime(
        key: PrayerType.fajr,
        time: pt.fajr.toLocal().add(dstOffset),
      ),
      PrayerTime(
        key: PrayerType.sunrise,
        time: pt.sunrise.toLocal().add(dstOffset),
      ),
      PrayerTime(
        key: PrayerType.dhuhr,
        time: pt.dhuhr.toLocal().add(dstOffset),
      ),
      PrayerTime(
        key: PrayerType.asr,
        time: pt.asr.toLocal().add(dstOffset),
      ),
      PrayerTime(
        key: PrayerType.maghrib,
        time: pt.maghrib.toLocal().add(dstOffset),
      ),
      PrayerTime(
        key: PrayerType.isha,
        time: pt.isha.toLocal().add(dstOffset),
      ),
    ];

    return PrayerDay(
      date: calcDate,
      location: location,
      times: times,
    );
  }

  adhan.CalculationParameters _resolveParameters(
    CalculationMethodSetting setting,
    String countryCode,
  ) {
    if (setting.method != CalculationMethod.auto) {
      return _parametersForMethod(setting.method);
    }
    return _autoSelectForCountry(countryCode.toUpperCase());
  }

  adhan.CalculationParameters _autoSelectForCountry(String countryCode) {
    switch (countryCode) {
      case 'EG':
        return adhan.CalculationMethodParameters.egyptian();
      case 'SA':
        return adhan.CalculationMethodParameters.ummAlQura();
      case 'AE':
        return adhan.CalculationMethodParameters.dubai();
      case 'QA':
        return adhan.CalculationMethodParameters.qatar();
      case 'KW':
        return adhan.CalculationMethodParameters.kuwait();
      case 'JO':
        return adhan.CalculationMethodParameters.jordan();
      case 'MA':
        return adhan.CalculationMethodParameters.morocco();
      case 'DZ':
        return adhan.CalculationMethodParameters.algerian();
      case 'TN':
        return adhan.CalculationMethodParameters.tunisia();
      case 'TR':
        return adhan.CalculationMethodParameters.turkiye();
      case 'PK':
      case 'BD':
      case 'IN':
      case 'AF':
        return adhan.CalculationMethodParameters.karachi();
      case 'US':
      case 'CA':
        return adhan.CalculationMethodParameters.northAmerica();
      case 'RU':
        return adhan.CalculationMethodParameters.russia();
      case 'SG':
        return adhan.CalculationMethodParameters.singapore();
      case 'ID':
        return adhan.CalculationMethodParameters.indonesian();
      default:
        return adhan.CalculationMethodParameters.muslimWorldLeague();
    }
  }

  adhan.CalculationParameters _parametersForMethod(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.egyptian:
        return adhan.CalculationMethodParameters.egyptian();
      case CalculationMethod.ummAlQura:
        return adhan.CalculationMethodParameters.ummAlQura();
      case CalculationMethod.muslimWorldLeague:
        return adhan.CalculationMethodParameters.muslimWorldLeague();
      case CalculationMethod.isna:
        return adhan.CalculationMethodParameters.northAmerica();
      case CalculationMethod.karachi:
        return adhan.CalculationMethodParameters.karachi();
      case CalculationMethod.kuwait:
        return adhan.CalculationMethodParameters.kuwait();
      case CalculationMethod.qatar:
        return adhan.CalculationMethodParameters.qatar();
      case CalculationMethod.dubai:
        return adhan.CalculationMethodParameters.dubai();
      case CalculationMethod.turkey:
        return adhan.CalculationMethodParameters.turkiye();
      case CalculationMethod.tehran:
        return adhan.CalculationMethodParameters.tehran();
      case CalculationMethod.auto:
        return adhan.CalculationMethodParameters.egyptian();
    }
  }
}
