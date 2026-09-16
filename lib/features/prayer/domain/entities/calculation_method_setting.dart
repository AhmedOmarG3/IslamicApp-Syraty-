import 'package:equatable/equatable.dart';

enum CalculationMethod {
  auto,
  egyptian,
  ummAlQura,
  muslimWorldLeague,
  isna,
  karachi,
  kuwait,
  qatar,
  dubai,
  turkey,
  tehran,
}

enum AsrMadhab {
  shafi, // Standard (Shafi, Maliki, Hanbali)
  hanafi,
}

class CalculationMethodSetting extends Equatable {
  final CalculationMethod method;
  final AsrMadhab asrMadhab;

  const CalculationMethodSetting({
    this.method = CalculationMethod.auto,
    this.asrMadhab = AsrMadhab.shafi,
  });

  String get methodArabicName {
    switch (method) {
      case CalculationMethod.auto:
        return 'تلقائي (حسب الدولة)';
      case CalculationMethod.egyptian:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.ummAlQura:
        return 'أم القرى - مكة المكرمة';
      case CalculationMethod.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.isna:
        return 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
      case CalculationMethod.kuwait:
        return 'الكويت';
      case CalculationMethod.qatar:
        return 'قطر';
      case CalculationMethod.dubai:
        return 'دبي والإمارات';
      case CalculationMethod.turkey:
        return 'رئاسة الشؤون الدينية بتركيا (ديانت)';
      case CalculationMethod.tehran:
        return 'معهد لواء الجيوفيزياء بطهران';
    }
  }

  String get madhabArabicName {
    switch (asrMadhab) {
      case AsrMadhab.shafi:
        return 'الجمهور (شافعي، مالكي، حنبلي)';
      case AsrMadhab.hanafi:
        return 'حنفي';
    }
  }

  CalculationMethodSetting copyWith({
    CalculationMethod? method,
    AsrMadhab? asrMadhab,
  }) {
    return CalculationMethodSetting(
      method: method ?? this.method,
      asrMadhab: asrMadhab ?? this.asrMadhab,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.name,
      'asrMadhab': asrMadhab.name,
    };
  }

  factory CalculationMethodSetting.fromJson(Map<String, dynamic> json) {
    return CalculationMethodSetting(
      method: CalculationMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => CalculationMethod.auto,
      ),
      asrMadhab: AsrMadhab.values.firstWhere(
        (e) => e.name == json['asrMadhab'],
        orElse: () => AsrMadhab.shafi,
      ),
    );
  }

  @override
  List<Object?> get props => [method, asrMadhab];
}
