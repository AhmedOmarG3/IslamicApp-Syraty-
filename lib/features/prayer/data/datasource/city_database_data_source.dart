import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../../domain/entities/prayer_location.dart';

class CityRecord {
  final String cityName;
  final String cityNameEn;
  final String countryName;
  final String countryNameEn;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezone;

  const CityRecord({
    required this.cityName,
    required this.cityNameEn,
    required this.countryName,
    required this.countryNameEn,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory CityRecord.fromJson(Map<String, dynamic> json) {
    return CityRecord(
      cityName: json['cityName'] as String,
      cityNameEn: json['cityNameEn'] as String,
      countryName: json['countryName'] as String,
      countryNameEn: json['countryNameEn'] as String,
      countryCode: json['countryCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }

  PrayerLocation toPrayerLocation() {
    return PrayerLocation(
      cityName: cityName,
      countryName: countryName,
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}

abstract class CityDatabaseDataSource {
  Future<List<CityRecord>> getAllCities();
  Future<List<CityRecord>> searchCities(String query);
  Future<CityRecord?> findNearestCity(double latitude, double longitude);
}

class CityDatabaseDataSourceImpl implements CityDatabaseDataSource {
  final AssetBundle _assetBundle;
  List<CityRecord>? _cachedCities;

  CityDatabaseDataSourceImpl({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  @override
  Future<List<CityRecord>> getAllCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    try {
      final jsonString = await _assetBundle.loadString('assets/json/cities.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _cachedCities = jsonList
          .map((item) => CityRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      return _cachedCities!;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CityRecord>> searchCities(String query) async {
    final cities = await getAllCities();
    final cleanQuery = _normalize(query.trim());
    if (cleanQuery.isEmpty) return cities;

    return cities.where((c) {
      final normAr = _normalize(c.cityName);
      final normEn = c.cityNameEn.toLowerCase();
      final normCountryAr = _normalize(c.countryName);
      final normCountryEn = c.countryNameEn.toLowerCase();

      return normAr.contains(cleanQuery) ||
          normEn.contains(cleanQuery.toLowerCase()) ||
          normCountryAr.contains(cleanQuery) ||
          normCountryEn.contains(cleanQuery.toLowerCase());
    }).toList();
  }

  @override
  Future<CityRecord?> findNearestCity(double latitude, double longitude) async {
    final cities = await getAllCities();
    if (cities.isEmpty) return null;

    CityRecord? closest;
    double minDistance = double.infinity;

    for (final city in cities) {
      final dist = _haversineDistance(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        closest = city;
      }
    }

    return closest;
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  String _normalize(String input) {
    var s = input.toLowerCase();
    // Normalize Arabic alef forms
    s = s.replaceAll(RegExp(r'[أإآا]'), 'ا');
    // Normalize Taa Marbuta & Haa
    s = s.replaceAll('ة', 'ه');
    // Normalize Yaa
    s = s.replaceAll('ى', 'ي');
    // Remove Arabic diacritics
    s = s.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    return s;
  }
}
