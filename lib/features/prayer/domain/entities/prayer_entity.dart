import 'package:equatable/equatable.dart';

class PrayerTimingsEntity extends Equatable {
  final List<String> azanTimes;
  final List<String> timesName;

  const PrayerTimingsEntity({
    required this.azanTimes,
    required this.timesName,
  });

  @override
  List<Object?> get props => [azanTimes, timesName];
}
