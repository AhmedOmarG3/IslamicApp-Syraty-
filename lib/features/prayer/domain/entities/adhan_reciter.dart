import 'package:equatable/equatable.dart';

class AdhanReciter extends Equatable {
  final String id;
  final String displayName;
  final String assetPath;
  final String rawResourceName;
  final String? fajrAssetPath;
  final String? fajrRawResourceName;

  const AdhanReciter({
    required this.id,
    required this.displayName,
    required this.assetPath,
    required this.rawResourceName,
    this.fajrAssetPath,
    this.fajrRawResourceName,
  });

  String getAssetPathFor({bool isFajr = false}) {
    if (isFajr && fajrAssetPath != null) {
      return fajrAssetPath!;
    }
    return assetPath;
  }

  String getRawResourceFor({bool isFajr = false}) {
    if (isFajr && fajrRawResourceName != null) {
      return fajrRawResourceName!;
    }
    return rawResourceName;
  }

  static const defaultReciter = AdhanReciter(
    id: 'makkah',
    displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
    assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
    rawResourceName: 'adhan_makkah',
    fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
    fajrRawResourceName: 'adhan_makkah_fajr',
  );

  /// Reciters available for regular prayers (Dhuhr, Asr, Maghrib, Isha)
  static const List<AdhanReciter> regularReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
      rawResourceName: 'adhan_makkah',
      fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'ismail',
      displayName: 'أذان الشيخ مصطفى إسماعيل',
      assetPath: 'assets/audio/adhan/adhan_ismail.mp3',
      rawResourceName: 'adhan_ismail',
      fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
  ];

  /// Reciters available specifically for Fajr prayer
  static const List<AdhanReciter> fajrReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
      rawResourceName: 'adhan_makkah',
      fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'alafasy',
      displayName: 'أذان الشيخ مشاري راشد العفاسي',
      assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
      rawResourceName: 'adhan_makkah',
      fajrAssetPath: 'assets/audio/adhan/adhan_alafasy_fajr.mp3',
      fajrRawResourceName: 'adhan_alafasy_fajr',
    ),
  ];

  static const List<AdhanReciter> availableReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
      rawResourceName: 'adhan_makkah',
      fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'alafasy',
      displayName: 'أذان الشيخ مشاري راشد العفاسي',
      assetPath: 'assets/audio/adhan/adhan_makkah.mp3',
      rawResourceName: 'adhan_makkah',
      fajrAssetPath: 'assets/audio/adhan/adhan_alafasy_fajr.mp3',
      fajrRawResourceName: 'adhan_alafasy_fajr',
    ),
    AdhanReciter(
      id: 'ismail',
      displayName: 'أذان الشيخ مصطفى إسماعيل',
      assetPath: 'assets/audio/adhan/adhan_ismail.mp3',
      rawResourceName: 'adhan_ismail',
      fajrAssetPath: 'assets/audio/adhan/adhan_makkah_fajr.mp3',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
  ];

  static AdhanReciter getById(String id) {
    return availableReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => defaultReciter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'assetPath': assetPath,
      'rawResourceName': rawResourceName,
      'fajrAssetPath': fajrAssetPath,
      'fajrRawResourceName': fajrRawResourceName,
    };
  }

  factory AdhanReciter.fromJson(Map<String, dynamic> json) {
    return getById(json['id'] as String? ?? 'makkah');
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        assetPath,
        rawResourceName,
        fajrAssetPath,
        fajrRawResourceName,
      ];
}
