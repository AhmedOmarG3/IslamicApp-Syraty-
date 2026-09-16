import 'package:quran/quran.dart' as quran;
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/entities/mushaf_page_entity.dart';
import 'package:siraty/features/quran/domain/entities/surah_entity.dart';
import 'package:siraty/features/quran/domain/entities/verse_entity.dart';

/// Service responsible for constructing authoritative [MushafPage] objects
/// adhering to the 604-page King Fahd Complex Madinah Mushaf standard.
class MushafPageService {
  /// Total number of pages in the standard Madinah Mushaf.
  static const int totalPages = 604;

  /// Builds a [MushafPage] for [pageNumber] (1..604) using authoritative
  /// page mapping and the provided [surahs].
  static MushafPage buildMushafPage(int pageNumber, List<SurahEntity> surahs) {
    assert(pageNumber >= 1 && pageNumber <= totalPages,
        'Page must be between 1 and $totalPages');
    final pageData = quran.getPageData(pageNumber);

    final List<MushafPageSegment> segments = [];
    int juzNumber = 1;

    for (int i = 0; i < pageData.length; i++) {
      final item = pageData[i];
      final int surahNum = item['surah'] as int;
      final int startAyah = item['start'] as int;
      final int endAyah = item['end'] as int;

      if (i == 0) {
        juzNumber = quran.getJuzNumber(surahNum, startAyah);
      }

      final surahIndex = surahNum - 1;
      final surah = (surahIndex >= 0 && surahIndex < surahs.length)
          ? surahs[surahIndex]
          : null;

      final surahName = surah != null
          ? surah.surahName
          : (surahNum >= 1 && surahNum <= SurahModel.surahNamesList.length
              ? SurahModel.surahNamesList[surahNum - 1]
              : '');

      final isMakki = QuranMetadata.isMakki(surahNum);
      final isSurahStart = startAyah == 1;

      final List<VerseEntity> verses = [];
      if (surah != null && surah.verses.isNotEmpty) {
        for (int a = startAyah; a <= endAyah; a++) {
          final verseIndex = a - 1;
          if (verseIndex >= 0 && verseIndex < surah.verses.length) {
            verses.add(surah.verses[verseIndex]);
          } else {
            verses.add(VerseEntity(
              chapter: surahNum,
              verse: a,
              text: quran.getVerse(surahNum, a, verseEndSymbol: false),
            ));
          }
        }
      } else {
        for (int a = startAyah; a <= endAyah; a++) {
          verses.add(VerseEntity(
            chapter: surahNum,
            verse: a,
            text: quran.getVerse(surahNum, a, verseEndSymbol: false),
          ));
        }
      }

      segments.add(MushafPageSegment(
        surahNumber: surahNum,
        surahName: surahName,
        isMakki: isMakki,
        isSurahStart: isSurahStart,
        verses: verses,
      ));
    }

    return MushafPage(
      pageNumber: pageNumber,
      juzNumber: juzNumber,
      segments: segments,
    );
  }

  /// Get the page number (1..604) for a specific verse.
  static int getPageNumber(int surahNumber, int ayahNumber) {
    return quran.getPageNumber(surahNumber, ayahNumber);
  }

  /// Get all pages (1..604) spanned by a Surah.
  static List<int> getSurahPages(int surahNumber) {
    final pages = quran.getSurahPages(surahNumber);
    return List<int>.from(pages);
  }

  /// Format page number as Arabic numeral string (e.g. '٤٥')
  static String toArabicPageNumber(int pageNumber) {
    return QuranMetadata.toArabicDigits(pageNumber);
  }
}
