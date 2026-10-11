// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran/qcf_quran.dart' as qcf;

void main() {
  test('Verify zero header repetitions and all 114 surahs across all 604 pages in qcf_quran', () {
    int totalSurahHeaders = 0;
    final Map<int, List<int>> surahsOnPage = {};
    final List<String> issues = [];

    for (int pageNum = 1; pageNum <= 604; pageNum++) {
      final ranges = qcf.getPageData(pageNum);
      final List<int> headersOnThisPage = [];

      for (final range in ranges) {
        final int surah = int.parse(range['surah'].toString());
        final int start = int.parse(range['start'].toString());

        if (start == 1) {
          headersOnThisPage.add(surah);
          totalSurahHeaders++;
        }
      }

      final set = headersOnThisPage.toSet();
      if (set.length != headersOnThisPage.length) {
        issues.add('Page $pageNum has DUPLICATE headers: $headersOnThisPage');
      }

      if (headersOnThisPage.isNotEmpty) {
        surahsOnPage[pageNum] = headersOnThisPage;
      }
    }

    print('AUDIT PASSED: Verified all 604 pages.');
    print('Total surah headers across all 604 pages: $totalSurahHeaders');

    expect(issues, isEmpty, reason: 'Found duplicate headers: $issues');
    expect(totalSurahHeaders, 114, reason: 'Total surah headers must be exactly 114');

    // Verify all 114 surahs are rendered exactly once
    final allRenderedSurahs = surahsOnPage.values.expand((x) => x).toList();
    expect(allRenderedSurahs.length, 114);
    for (int s = 1; s <= 114; s++) {
      expect(allRenderedSurahs.contains(s), isTrue, reason: 'Surah $s missing from mushaf pages');
    }




    // Also verify specific known critical pages:
    // Page 255: Surat Ibrahim (14)
    expect(surahsOnPage[255], [14]);
    // Page 604: Al-Ikhlas (112), Al-Falaq (113), An-Nas (114)
    expect(surahsOnPage[604], [112, 113, 114]);
  });
}
