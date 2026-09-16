import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../data/models/azan_model.dart';
import '../../data/models/prayer_snapshot_model.dart';
import '../../domain/entities/prayer_day.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_next_prayer_usecase.dart';

abstract class AzanState extends Equatable {
  const AzanState();

  @override
  List<Object?> get props => [];
}

class AzanInitial extends AzanState {}

class AzanLoadingState extends AzanState {}

class AzanLoadedState extends AzanState {
  final PrayerSnapshotModel snapshot;
  final PrayerDay derivedToday;
  final NextPrayerResult? nextPrayer;
  final Duration? countdown;
  final bool isLocationAutoDetected;

  const AzanLoadedState({
    required this.snapshot,
    required this.derivedToday,
    this.nextPrayer,
    this.countdown,
    this.isLocationAutoDetected = false,
  });

  /// Formats the countdown into HH:mm:ss or mm:ss in Arabic digits
  String get formattedCountdown {
    if (countdown == null) return '--:--:--';
    final totalSeconds = countdown!.inSeconds.abs();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    final en = hours > 0 ? '$hStr:$mStr:$sStr' : '$mStr:$sStr';
    // Convert to Arabic-Indic digits
    return _toArabicDigits(en);
  }

  static String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// Backward-compatibility helper for any legacy widget using AzanModel
  AzanModel get azanList {
    final formatter = DateFormat('hh:mm a', 'ar');
    final times = derivedToday.times
        .where((t) => t.key != PrayerType.sunrise)
        .map((t) => formatter.format(t.time))
        .toList();
    final names = derivedToday.times
        .where((t) => t.key != PrayerType.sunrise)
        .map((t) => t.arabicName)
        .toList();
    return AzanModel(azanTimes: times, timesName: names);
  }

  AzanLoadedState copyWith({
    PrayerSnapshotModel? snapshot,
    PrayerDay? derivedToday,
    NextPrayerResult? nextPrayer,
    Duration? countdown,
    bool? isLocationAutoDetected,
  }) {
    return AzanLoadedState(
      snapshot: snapshot ?? this.snapshot,
      derivedToday: derivedToday ?? this.derivedToday,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      countdown: countdown ?? this.countdown,
      isLocationAutoDetected:
          isLocationAutoDetected ?? this.isLocationAutoDetected,
    );
  }

  @override
  List<Object?> get props => [
        snapshot,
        derivedToday,
        nextPrayer?.prayer,
        nextPrayer?.isTomorrow,
        countdown?.inSeconds,
        isLocationAutoDetected,
      ];
}

class AzanFailureState extends AzanState {
  final String errorMessage;

  const AzanFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
