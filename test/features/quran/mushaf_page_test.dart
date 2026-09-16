import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;
import 'package:siraty/features/quran/domain/entities/surah_entity.dart';
import 'package:siraty/features/quran/domain/entities/verse_entity.dart';
import 'package:siraty/features/quran/domain/services/mushaf_page_service.dart';

void main() {
  group('MushafPageService and 604-page Authoritative Mapping Tests', () {
    // Mock minimal surahs list
    final dummySurahs = List.generate(114, (i) {
      final sNum = i + 1;
      final count = quran.getVerseCount(sNum);
      return SurahEntity(
        surahNumber: sNum,
        surahName: quran.getSurahNameArabic(sNum),
        verses: List.generate(
          count,
          (v) => VerseEntity(
            chapter: sNum,
            verse: v + 1,
            text: quran.getVerse(sNum, v + 1, verseEndSymbol: false),
          ),
        ),
      );
    });

    test('Total Mushaf pages equals 604', () {
      expect(MushafPageService.totalPages, 604);
    });

    test('Page 1 corresponds exactly to Surat Al-Fatiha (verses 1-7)', () {
      final page = MushafPageService.buildMushafPage(1, dummySurahs);
      expect(page.pageNumber, 1);
      expect(page.juzNumber, 1);
      expect(page.segments.length, 1);

      final seg = page.segments.first;
      expect(seg.surahNumber, 1);
      expect(seg.surahName, 'الفاتحة');
      expect(seg.isMakki, true);
      expect(seg.isSurahStart, true);
      expect(seg.verses.length, 7);
      expect(seg.verses.first.verse, 1);
      expect(seg.verses.last.verse, 7);
      expect(page.containsVerse(1, 1), true);
      expect(page.containsVerse(1, 7), true);
      expect(page.containsVerse(1, 8), false);
    });

    test('Page 2 corresponds to Surat Al-Baqarah start (verses 1-5)', () {
      final page = MushafPageService.buildMushafPage(2, dummySurahs);
      expect(page.pageNumber, 2);
      expect(page.juzNumber, 1);
      expect(page.segments.length, 1);

      final seg = page.segments.first;
      expect(seg.surahNumber, 2);
      expect(seg.surahName, 'البقرة');
      expect(seg.isMakki, false);
      expect(seg.isSurahStart, true);
      expect(seg.verses.length, 5);
      expect(seg.verses.first.verse, 1);
      expect(seg.verses.last.verse, 5);
    });

    test('Page 3 continues Surat Al-Baqarah (verses 6-16)', () {
      final page = MushafPageService.buildMushafPage(3, dummySurahs);
      expect(page.pageNumber, 3);
      expect(page.segments.length, 1);

      final seg = page.segments.first;
      expect(seg.surahNumber, 2);
      expect(seg.isSurahStart, false);
      expect(seg.verses.first.verse, 6);
      expect(seg.verses.last.verse, 16);
    });

    test('Page 604 contains Surahs Al-Ikhlas, Al-Falaq, and An-Nas', () {
      final page = MushafPageService.buildMushafPage(604, dummySurahs);
      expect(page.pageNumber, 604);
      expect(page.juzNumber, 30);
      expect(page.segments.length, 3);

      expect(page.segments[0].surahNumber, 112);
      expect(page.segments[0].isSurahStart, true);
      expect(page.segments[0].verses.length, 4);

      expect(page.segments[1].surahNumber, 113);
      expect(page.segments[1].isSurahStart, true);
      expect(page.segments[1].verses.length, 5);

      expect(page.segments[2].surahNumber, 114);
      expect(page.segments[2].isSurahStart, true);
      expect(page.segments[2].verses.length, 6);

      expect(page.totalVersesCount, 15);
      expect(page.containsVerse(112, 1), true);
      expect(page.containsVerse(113, 3), true);
      expect(page.containsVerse(114, 6), true);
    });

    test('Verse page mapping helper returns authoritative pages', () {
      expect(MushafPageService.getPageNumber(1, 1), 1);
      expect(MushafPageService.getPageNumber(1, 7), 1);
      expect(MushafPageService.getPageNumber(2, 1), 2);
      expect(MushafPageService.getPageNumber(2, 5), 2);
      expect(MushafPageService.getPageNumber(2, 6), 3);
      expect(MushafPageService.getPageNumber(114, 6), 604);
    });

    test('Every page from 1 to 604 builds valid segments without errors', () {
      for (int p = 1; p <= 604; p++) {
        final page = MushafPageService.buildMushafPage(p, dummySurahs);
        expect(page.pageNumber, p);
        expect(page.juzNumber >= 1 && page.juzNumber <= 30, true);
        expect(page.segments.isNotEmpty, true);
        expect(page.totalVersesCount > 0, true);
      }
    });
  });
}
