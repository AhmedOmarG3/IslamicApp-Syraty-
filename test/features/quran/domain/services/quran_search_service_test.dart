import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/domain/services/quran_search_service.dart';

void main() {
  group('QuranSearchService Normalization Tests', () {
    test('Normalizes dagger alif correctly for words like مالك and الصراط', () {
      // مَٰلِكِ in Uthmani -> مالك
      final normalizedMalik = QuranSearchService.normalizeArabic('مَٰلِكِ يَوْمِ الدِّينِ');
      expect(normalizedMalik, contains('مالك'));

      // ٱلصِّرَٰطَ in Uthmani -> الصراط
      final normalizedSirat = QuranSearchService.normalizeArabic('ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ');
      expect(normalizedSirat, contains('الصراط'));
    });

    test('Normalizes Uthmani waw-dagger-alif for prayer, zakat, and life words', () {
      // ٱلصَّلَوٰةَ -> الصلاه / الصلاة
      final normalizedSalah = QuranSearchService.normalizeArabic('وَيُقِيمُونَ ٱلصَّلَوٰةَ');
      final querySalah = QuranSearchService.normalizeArabic('الصلاة');
      expect(normalizedSalah, contains(querySalah));

      // ٱلزَّكَوٰةَ -> الزكاه / الزكاة
      final normalizedZakah = QuranSearchService.normalizeArabic('وَءَاتُواْ ٱلزَّكَوٰةَ');
      final queryZakah = QuranSearchService.normalizeArabic('الزكاة');
      expect(normalizedZakah, contains(queryZakah));
    });

    test('Normalizes names with Uthmani script (Ibrahim, Ismail)', () {
      // إِبۡرَٰهَـۧمَ in Al-Baqarah
      const uthmaniIbrahim = 'وَإِذِ ٱبۡتَلَىٰٓ إِبۡرَٰهَـۧمَ رَبُّهُۥ';
      final normIbrahim = QuranSearchService.normalizeArabic(uthmaniIbrahim);
      final queryIbrahim = QuranSearchService.normalizeArabic('ابراهيم');
      expect(normIbrahim, contains(queryIbrahim));

      // إِسۡمَٰعِيلَ
      const uthmaniIsmail = 'وَإِسۡمَٰعِيلَ وَإِسۡحَٰقَ';
      final normIsmail = QuranSearchService.normalizeArabic(uthmaniIsmail);
      final queryIsmail = QuranSearchService.normalizeArabic('اسماعيل');
      expect(normIsmail, contains(queryIsmail));
    });

    test('Matches dual spellings of سماوات and سموات', () {
      const uthmaniSamawat = 'فَسَوَّىٰهُنَّ سَبۡعَ سَمَٰوَٰتٖ';
      final normVerse = QuranSearchService.normalizeArabic(uthmaniSamawat);

      final q1 = QuranSearchService.normalizeArabic('سموات');
      final q2 = QuranSearchService.normalizeArabic('سماوات');

      expect(normVerse, contains(q1));
      expect(normVerse, contains(q2));
    });

    test('Handles Ayat Al-Kursi search without tashkeel or hamzas', () {
      const verseText =
          'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُۚ لَا تَأۡخُذُهُۥ سِنَةٞ وَلَا نَوۡمٞۚ';
      final normVerse = QuranSearchService.normalizeArabic(verseText);

      final query1 = QuranSearchService.normalizeArabic('الله لا اله الا هو الحي القيوم');
      final query2 = QuranSearchService.normalizeArabic('الله لا إله إلا هو الحي القيوم');

      expect(normVerse, contains(query1));
      expect(normVerse, contains(query2));
    });
  });
}
