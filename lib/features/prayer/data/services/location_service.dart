import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/prayer_location.dart';
import '../datasource/city_database_data_source.dart';

abstract class LocationService {
  Future<PrayerLocation?> detectCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
}

class LocationServiceImpl implements LocationService {
  final CityDatabaseDataSource _cityDatabase;

  LocationServiceImpl({required CityDatabaseDataSource cityDatabase})
      : _cityDatabase = cityDatabase;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  @override
  Future<PrayerLocation?> detectCurrentLocation() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 6),
        ),
      );

      // Find nearest city in bundled offline database
      final nearestCity = await _cityDatabase.findNearestCity(
        position.latitude,
        position.longitude,
      );

      // Get device timezone or city timezone
      String timezone;
      try {
        timezone = await FlutterTimezone.getLocalTimezone();
      } catch (_) {
        timezone = nearestCity?.timezone ?? 'Africa/Cairo';
      }

      if (nearestCity != null) {
        return PrayerLocation(
          cityName: nearestCity.cityName,
          countryName: nearestCity.countryName,
          countryCode: nearestCity.countryCode,
          latitude: position.latitude,
          longitude: position.longitude,
          timezone: timezone,
        );
      }

      // Fallback if no near city found in database
      return PrayerLocation(
        cityName: 'موقعي الحالي',
        countryName: '',
        countryCode: 'EG',
        latitude: position.latitude,
        longitude: position.longitude,
        timezone: timezone,
      );
    } catch (_) {
      return null;
    }
  }
}
