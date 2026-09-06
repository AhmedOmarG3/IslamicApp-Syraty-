/// Quran Metadata helper providing Makki/Madani classification
/// and Juz naming matching standard Islamic scholarly references.
abstract class QuranMetadata {
  /// The 28 Madani Surahs. The remaining 86 are Makki.
  static const Set<int> _madaniSurahs = {
    2, 3, 4, 5, 8, 9, 13, 22, 24, 33, 47, 48, 49,
    55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 76,
    98, 99, 110
  };

  static bool isMakki(int surahNumber) => !_madaniSurahs.contains(surahNumber);

  static String getJuzName(int surahNumber) {
    if (surahNumber == 1) return 'الجزء الأول';
    if (surahNumber == 2) return 'الجزء الأول - الثالث';
    if (surahNumber == 3) return 'الجزء الثالث - الرابع';
    if (surahNumber == 4) return 'الجزء الرابع - السادس';
    if (surahNumber == 5) return 'الجزء السادس - السابع';
    if (surahNumber == 6) return 'الجزء السابع - الثامن';
    if (surahNumber == 7) return 'الجزء الثامن - التاسع';
    if (surahNumber == 8) return 'الجزء التاسع - العاشر';
    if (surahNumber == 9) return 'الجزء العاشر - الحادي عشر';
    if (surahNumber <= 11) return 'الجزء الحادي عشر - الثاني عشر';
    if (surahNumber <= 14) return 'الجزء الثالث عشر';
    if (surahNumber <= 16) return 'الجزء الرابع عشر';
    if (surahNumber <= 18) return 'الجزء الخامس عشر - السادس عشر';
    if (surahNumber <= 20) return 'الجزء السادس عشر';
    if (surahNumber <= 22) return 'الجزء السابع عشر';
    if (surahNumber <= 25) return 'الجزء الثامن عشر - التاسع عشر';
    if (surahNumber <= 27) return 'الجزء التاسع عشر - العشرين';
    if (surahNumber <= 29) return 'الجزء العشرين - الحادي والعشرين';
    if (surahNumber <= 33) return 'الجزء الحادي والعشرين - الثاني والعشرين';
    if (surahNumber <= 36) return 'الجزء الثاني والعشرين - الثالث والعشرين';
    if (surahNumber <= 39) return 'الجزء الثالث والعشرين - الرابع والعشرين';
    if (surahNumber <= 45) return 'الجزء الرابع والعشرين - السادس والعشرين';
    if (surahNumber <= 51) return 'الجزء السادس والعشرين - السابع والعشرين';
    if (surahNumber <= 57) return 'الجزء السابع والعشرين';
    if (surahNumber <= 66) return 'الجزء الثامن والعشرين';
    if (surahNumber <= 77) return 'الجزء التاسع والعشرين (تبارك)';
    return 'الجزء الثلاثون (عمّ)';
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
      'الجزء التاسع والعشرون (تبارك)',
      'الجزء الثلاثون (عمّ)',
    ];
    if (juzNumber >= 1 && juzNumber <= 30) {
      return names[juzNumber - 1];
    }
    return 'الجزء $juzNumber';
  }

  static String toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? arabicDigits[d] : c;
    }).join();
  }
}
