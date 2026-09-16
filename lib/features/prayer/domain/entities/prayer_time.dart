import 'package:equatable/equatable.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

enum PrayerStatus {
  passed,
  current,
  upcoming,
}

class PrayerTime extends Equatable {
  final PrayerType key;
  final DateTime time;
  final PrayerStatus status;

  const PrayerTime({
    required this.key,
    required this.time,
    this.status = PrayerStatus.upcoming,
  });

  bool get isPrayer => key != PrayerType.sunrise;

  String get arabicName {
    switch (key) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  PrayerTime copyWith({
    PrayerType? key,
    DateTime? time,
    PrayerStatus? status,
  }) {
    return PrayerTime(
      key: key ?? this.key,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [key, time, status];
}
