import 'package:equatable/equatable.dart';

class PrayerLocation extends Equatable {
  final String cityName;
  final String countryName;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezone;

  const PrayerLocation({
    required this.cityName,
    required this.countryName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  PrayerLocation copyWith({
    String? cityName,
    String? countryName,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? timezone,
  }) {
    return PrayerLocation(
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'countryName': countryName,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  factory PrayerLocation.fromJson(Map<String, dynamic> json) {
    return PrayerLocation(
      cityName: json['cityName'] as String? ?? 'القاهرة',
      countryName: json['countryName'] as String? ?? 'مصر',
      countryCode: json['countryCode'] as String? ?? 'EG',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
      timezone: json['timezone'] as String? ?? 'Africa/Cairo',
    );
  }

  static const defaultLocation = PrayerLocation(
    cityName: 'القاهرة',
    countryName: 'مصر',
    countryCode: 'EG',
    latitude: 30.0444,
    longitude: 31.2357,
    timezone: 'Africa/Cairo',
  );

  @override
  List<Object?> get props => [
        cityName,
        countryName,
        countryCode,
        latitude,
        longitude,
        timezone,
      ];
}
