import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

void main() {
  group('QuranMetadata.getJuzName tests', () {
    test('Surah Al-Baqarah returns single clean juz name', () {
      final juz = QuranMetadata.getJuzName(2);
      expect(juz, 'الجزء الأول');
      expect(juz.contains('-'), false);
    });

    test('Surah Aal-Imran returns clean starting juz without trailing span', () {
      final juz = QuranMetadata.getJuzName(3);
      expect(juz, 'الجزء الثالث');
      expect(juz.contains('-'), false);
      expect(juz.contains('الرابع'), false);
    });

    test('Surah An-Nisa returns clean starting juz', () {
      final juz = QuranMetadata.getJuzName(4);
      expect(juz, 'الجزء الرابع');
      expect(juz.contains('-'), false);
    });

    test('All 114 surahs return valid clean juz name without dashes', () {
      for (int i = 1; i <= 114; i++) {
        final name = QuranMetadata.getJuzName(i);
        expect(name.contains('-'), false, reason: 'Surah $i has dash: $name');
        expect(name.startsWith('الجزء'), true, reason: 'Surah $i prefix: $name');
      }
    });

    test('Start-juz values match standard Madinah mushaf boundaries', () {
      // (surah number, expected starting juz)
      const boundaries = <int, int>{
        1: 1,
        2: 1,
        3: 3,
        4: 4,
        5: 6,
        33: 21,
        46: 26,
        58: 28,
        67: 29,
        78: 30,
        114: 30,
      };
      boundaries.forEach((surah, juz) {
        expect(
          QuranMetadata.getSurahStartJuz(surah),
          juz,
          reason: 'Surah $surah should start at juz $juz',
        );
      });
    });

    test('Makki/Madani classification spot checks', () {
      expect(QuranMetadata.isMakki(1), true);
      expect(QuranMetadata.isMakki(2), false); // Al-Baqarah is Madani
      expect(QuranMetadata.isMakki(110), false); // An-Nasr is Madani
      expect(QuranMetadata.isMakki(112), true);
    });
  });
}
