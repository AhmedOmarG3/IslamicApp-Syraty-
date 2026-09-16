/// Quran Metadata helper providing Makki/Madani classification
/// and Juz naming matching standard Islamic scholarly references.
abstract class QuranMetadata {
  /// The 28 Madani Surahs. The remaining 86 are Makki.
  static const Set<int> _madaniSurahs = {
    2,
    3,
    4,
    5,
    8,
    9,
    13,
    22,
    24,
    33,
    47,
    48,
    49,
    55,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    76,
    98,
    99,
    110
  };

  static bool isMakki(int surahNumber) => !_madaniSurahs.contains(surahNumber);

  static int getSurahStartJuz(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return 1;
    const surahJuzMap = [
      1, 1, 3, 4, 6, 7, 8, 9, 10, 11, // 1 - 10
      11, 12, 13, 13, 14, 14, 15, 15, 16, 16, // 11 - 20
      17, 17, 18, 18, 18, 19, 19, 20, 20, 21, // 21 - 30
      21, 21, 21, 22, 22, 22, 23, 23, 23, 24, // 31 - 40
      24, 25, 25, 25, 25, 26, 26, 26, 26, 26, // 41 - 50
      26, 27, 27, 27, 27, 27, 27, 28, 28, 28, // 51 - 60
      28, 28, 28, 28, 28, 28, 29, 29, 29, 29, // 61 - 70
      29, 29, 29, 29, 29, 29, 29, // 71 - 77
    ];
    if (surahNumber <= 77) {
      return surahJuzMap[surahNumber - 1];
    }
    return 30;
  }

  static String getJuzName(int surahNumber) {
    final juzNum = getSurahStartJuz(surahNumber);
    return getJuzNameFromNumber(juzNum);
  }

  static String getJuzNameFromNumber(int juzNumber) {
    const names = [
      'الجزء الأول',
      'الجزء الثاني',
      'الجزء الثالث',
      'الجزء الرابع',
      'الجزء الخامس',
      'الجزء السادس',
      'الجزء السابع',
      'الجزء الثامن',
      'الجزء التاسع',
      'الجزء العاشر',
      'الجزء الحادي عشر',
      'الجزء الثاني عشر',
      'الجزء الثالث عشر',
      'الجزء الرابع عشر',
      'الجزء الخامس عشر',
      'الجزء السادس عشر',
      'الجزء السابع عشر',
      'الجزء الثامن عشر',
      'الجزء التاسع عشر',
      'الجزء العشرون',
      'الجزء الحادي والعشرون',
      'الجزء الثاني والعشرون',
      'الجزء الثالث والعشرون',
      'الجزء الرابع والعشرون',
      'الجزء الخامس والعشرون',
      'الجزء السادس والعشرون',
      'الجزء السابع والعشرون',
      'الجزء الثامن والعشرون',
      'الجزء التاسع والعشرون',
      'الجزء الثلاثون',
    ];
    if (juzNumber >= 1 && juzNumber <= 30) {
      return names[juzNumber - 1];
    }
    return 'الجزء $juzNumber';
  }

  static String toArabicDigits(Object number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? arabicDigits[d] : c;
    }).join();
  }
}
