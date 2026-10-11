import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/hadith/data/models/hadith_model.dart';
import 'package:siraty/features/hadith/data/services/hadith_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HadithModel Tests', () {
    test('fromJson and toJson maintain integrity', () {
      final json = {
        'id': 1,
        'title': 'إنما الأعمال بالنيات',
        'narrator': 'عمر بن الخطاب',
        'arabic': 'إنما الأعمال بالنيات',
        'source': 'صحيح البخاري',
        'category': 'الإيمان والنيات',
        'explanation': 'شرح الحديث',
      };

      final model = HadithModel.fromJson(json);
      expect(model.id, 1);
      expect(model.title, 'إنما الأعمال بالنيات');
      expect(model.narrator, 'عمر بن الخطاب');
      expect(model.source, 'صحيح البخاري');
      expect(model.category, 'الإيمان والنيات');

      final backToJson = model.toJson();
      expect(backToJson['id'], 1);
      expect(backToJson['title'], 'إنما الأعمال بالنيات');
    });

    test('props equality works correctly', () {
      const h1 = HadithModel(
        id: 1,
        title: 'T',
        narrator: 'N',
        arabic: 'A',
        source: 'S',
        category: 'C',
        explanation: 'E',
      );
      const h2 = HadithModel(
        id: 1,
        title: 'T',
        narrator: 'N',
        arabic: 'A',
        source: 'S',
        category: 'C',
        explanation: 'E',
      );

      expect(h1, equals(h2));
    });
  });

  group('HadithService Logic Tests', () {
    final sampleList = [
      const HadithModel(
        id: 1,
        title: 'إنما الأعمال بالنيات',
        narrator: 'عمر بن الخطاب',
        arabic: 'إنما الأعمال بالنيات وإنما لكل امرئ ما نوى',
        source: 'صحيح البخاري',
        category: 'الإيمان',
        explanation: 'النية شرط',
      ),
      const HadithModel(
        id: 2,
        title: 'الصلوات الخمس',
        narrator: 'أبو هريرة',
        arabic: 'مثل الصلوات الخمس كمثل نهر جار',
        source: 'صحيح مسلم',
        book: 'صحيح مسلم',
        category: 'العبادات',
        explanation: 'تكفير الذنوب',
      ),
    ];

    test('getCategories includes الكل and all unique categories', () {
      final cats = HadithService.getCategories(sampleList);
      expect(cats, contains('الكل'));
      expect(cats, contains('الإيمان'));
      expect(cats, contains('العبادات'));
      expect(cats.length, 3);
    });

    test('filterByCategory filters correctly', () {
      final filtered = HadithService.filterByCategory(sampleList, 'العبادات');
      expect(filtered.length, 1);
      expect(filtered.first.id, 2);

      final all = HadithService.filterByCategory(sampleList, 'الكل');
      expect(all.length, 2);
    });

    test('searchHadiths searches title, text, narrator, and source', () {
      final byTitle = HadithService.searchHadiths(sampleList, 'الأعمال');
      expect(byTitle.length, 1);
      expect(byTitle.first.id, 1);

      final byNarrator = HadithService.searchHadiths(sampleList, 'هريرة');
      expect(byNarrator.length, 1);
      expect(byNarrator.first.id, 2);

      final bySource = HadithService.searchHadiths(sampleList, 'مسلم');
      expect(bySource.length, 1);
      expect(bySource.first.id, 2);

      final emptyResult = HadithService.searchHadiths(sampleList, 'غير موجود');
      expect(emptyResult.isEmpty, isTrue);
    });

    test('normalizeArabic strips tashkeel, normalizes hamza and taa marbuta', () {
      const raw = '«إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ...»';
      final normalized = HadithService.normalizeArabic(raw);
      expect(normalized, equals('انما الاعمال بالنيات'));

      const taaMarbuta = 'صَدَقَةٌ جَارِيَةٌ';
      expect(HadithService.normalizeArabic(taaMarbuta), equals('صدقه جاريه'));

      const alefMaqsura = 'إِلَى الهُدَى';
      expect(HadithService.normalizeArabic(alefMaqsura), equals('الي الهدي'));
    });

    test('searchHadiths accurately matches unvocalized query against vocalized hadiths', () {
      // User types without tashkeel or hamza
      final res1 = HadithService.searchHadiths(sampleList, 'الاعمال بالنيات');
      expect(res1.length, 1);
      expect(res1.first.id, 1);

      // User searches multiple keywords across fields
      final res2 = HadithService.searchHadiths(sampleList, 'عمر النيه');
      expect(res2.length, 1);
      expect(res2.first.id, 1);

      final res3 = HadithService.searchHadiths(sampleList, 'مسلم نهر');
      expect(res3.length, 1);
      expect(res3.first.id, 2);
    });

    test('getCategoryCounts calculates counts accurately', () {
      final counts = HadithService.getCategoryCounts(sampleList);
      expect(counts['الكل'], 2);
      expect(counts['الإيمان'], 1);
      expect(counts['العبادات'], 1);
    });

    test('getBooks and filterHadiths by book work accurately', () {
      final books = HadithService.getBooks(sampleList);
      expect(books, contains('الكل'));
      expect(books, contains('صحيح البخاري'));
      expect(books, contains('صحيح مسلم'));

      final bukhariHadiths = HadithService.filterHadiths(
        hadiths: sampleList,
        selectedBook: 'صحيح البخاري',
      );
      expect(bukhariHadiths.length, 1);
      expect(bukhariHadiths.first.id, 1);

      final muslimHadiths = HadithService.filterHadiths(
        hadiths: sampleList,
        selectedBook: 'صحيح مسلم',
      );
      expect(muslimHadiths.length, 1);
      expect(muslimHadiths.first.id, 2);
    });

    test('getChapters extracts unique chapters in order', () {
      final list = [
        const HadithModel(
          id: 1,
          title: 'حديث 1',
          narrator: '',
          arabic: 'متن',
          source: 'صحيح البخاري',
          book: 'صحيح البخاري',
          chapter: 'بدء الوحي',
          category: 'بدء الوحي',
          explanation: '',
        ),
        const HadithModel(
          id: 2,
          title: 'حديث 2',
          narrator: '',
          arabic: 'متن 2',
          source: 'صحيح البخاري',
          book: 'صحيح البخاري',
          chapter: 'الإيمان',
          category: 'الإيمان',
          explanation: '',
        ),
      ];

      final chapters = HadithService.getChapters(list);
      expect(chapters, contains('الكل'));
      expect(chapters, contains('بدء الوحي'));
      expect(chapters, contains('الإيمان'));
      expect(chapters.length, 3);
    });

    test('searchHadiths matches hadith number using Arabic and Latin digits', () {
      final list = [
        const HadithModel(
          id: 105,
          title: 'حديث رقم 105',
          narrator: 'صحابي',
          arabic: 'نص الحديث',
          source: 'صحيح البخاري',
          book: 'صحيح البخاري',
          chapter: 'الصلاة',
          category: 'الصلاة',
          explanation: '',
        ),
      ];

      // Match by Latin number
      final resLatin = HadithService.searchHadiths(list, '105');
      expect(resLatin.length, 1);
      expect(resLatin.first.id, 105);

      // Match by Arabic number
      final resArabic = HadithService.searchHadiths(list, '١٠٥');
      expect(resArabic.length, 1);
      expect(resArabic.first.id, 105);
    });

    test('HadithModel parses alternative fields like text and assigns default title', () {
      final json = {
        'id': 7,
        'book': 'صحيح البخاري',
        'chapter': 'بدء الوحي',
        'chapterId': 1,
        'text': 'نص الحديث الشريف كاملاً',
      };

      final model = HadithModel.fromJson(json);
      expect(model.id, 7);
      expect(model.arabic, 'نص الحديث الشريف كاملاً');
      expect(model.chapter, 'بدء الوحي');
      expect(model.chapterId, 1);
      expect(model.title, 'حديث رقم 7');
      expect(model.book, 'صحيح البخاري');
    });

    test('hadith.json parses all items successfully without any errors', () async {
      final hadithFile = io.File('assets/json/hadith.json');

      expect(hadithFile.existsSync(), isTrue);
      final hadithStr = await hadithFile.readAsString();
      final hadithList = HadithService.parseHadithsJsonString(hadithStr);
      expect(hadithList, isNotEmpty);
      expect(hadithList.first.id, 1);

      // Verify that 'الباب 0' placeholder is eliminated and correctly mapped
      final zeroChapters =
          hadithList.where((h) => h.chapter == 'الباب 0' || h.chapter == '0');
      expect(zeroChapters.isEmpty, isTrue);

      final chapters = HadithService.getChaptersWithCounts(hadithList);
      expect(chapters.any((c) => c.name.contains('0')), isFalse);
    });
  });
}


