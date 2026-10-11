import 'package:equatable/equatable.dart';

class AdhanReciter extends Equatable {
  final String id;
  final String displayName;
  final String rawResourceName;
  final String? fajrRawResourceName;

  const AdhanReciter({
    required this.id,
    required this.displayName,
    required this.rawResourceName,
    this.fajrRawResourceName,
  });

  /// The `res/raw` file holding the adhan used for [isFajr].
  String getRawResourceFor({bool isFajr = false}) {
    if (isFajr && fajrRawResourceName != null) {
      return fajrRawResourceName!;
    }
    return rawResourceName;
  }

  /// Android application id, used to address the bundled `res/raw` files.
  static const String androidPackage = 'com.ahmed.siraty';

  /// Playable URI for the in-app preview.
  ///
  /// The adhan ships exactly once, as `android/app/src/main/res/raw/*.mp3`,
  /// because `AdhanPlaybackService` plays the alarm straight from there. The
  /// preview reads the same file through an `android.resource://` URI rather
  /// than a second copy under `assets/audio/`, which would duplicate ~13.6 MB.
  String getPreviewUri({bool isFajr = false}) =>
      'android.resource://$androidPackage/raw/${getRawResourceFor(isFajr: isFajr)}';

  static const defaultReciter = AdhanReciter(
    id: 'makkah',
    displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
    rawResourceName: 'adhan_makkah',
    fajrRawResourceName: 'adhan_makkah_fajr',
  );

  /// Reciters available for regular prayers (Dhuhr, Asr, Maghrib, Isha)
  static const List<AdhanReciter> regularReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      rawResourceName: 'adhan_makkah',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'ismail',
      displayName: 'أذان الشيخ مصطفى إسماعيل',
      rawResourceName: 'adhan_ismail',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'tobar',
      displayName: 'أذان الشيخ نصر الدين طوبار',
      rawResourceName: 'nasr_topar',
      fajrRawResourceName: 'nasr_topar_figr',
    ),
  ];

  /// Reciters available specifically for Fajr prayer
  static const List<AdhanReciter> fajrReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      rawResourceName: 'adhan_makkah',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'alafasy',
      displayName: 'أذان الشيخ مشاري راشد العفاسي',
      rawResourceName: 'adhan_makkah',
      fajrRawResourceName: 'adhan_alafasy_fajr',
    ),
    AdhanReciter(
      id: 'tobar',
      displayName: 'أذان الشيخ نصر الدين طوبار',
      rawResourceName: 'nasr_topar',
      fajrRawResourceName: 'nasr_topar_figr',
    ),
  ];

  static const List<AdhanReciter> availableReciters = [
    AdhanReciter(
      id: 'makkah',
      displayName: 'أذان الحرم المكي (الشيخ علي أحمد ملا)',
      rawResourceName: 'adhan_makkah',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'alafasy',
      displayName: 'أذان الشيخ مشاري راشد العفاسي',
      rawResourceName: 'adhan_makkah',
      fajrRawResourceName: 'adhan_alafasy_fajr',
    ),
    AdhanReciter(
      id: 'ismail',
      displayName: 'أذان الشيخ مصطفى إسماعيل',
      rawResourceName: 'adhan_ismail',
      fajrRawResourceName: 'adhan_makkah_fajr',
    ),
    AdhanReciter(
      id: 'tobar',
      displayName: 'أذان الشيخ نصر الدين طوبار',
      rawResourceName: 'nasr_topar',
      fajrRawResourceName: 'nasr_topar_figr',
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
      'rawResourceName': rawResourceName,
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
        rawResourceName,
        fajrRawResourceName,
      ];
}
