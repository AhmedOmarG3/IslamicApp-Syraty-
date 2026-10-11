import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';

void main() {
  group('QuranDownloadService Unit Tests', () {
    test('Format bytes returns friendly human readable strings', () {
      expect(QuranDownloadService.formatBytes(0), '0 ميجابايت');
      expect(QuranDownloadService.formatBytes(512 * 1024), '512.0 كيلوبايت');
      expect(QuranDownloadService.formatBytes(2 * 1024 * 1024), '2.0 ميجابايت');
      expect(QuranDownloadService.formatBytes(25 * 1024 * 1024), '25.0 ميجابايت');
    });

    test('SurahDownloadProgress calculations', () {
      const progress = SurahDownloadProgress(
        reciterId: 'Alafasy_128kbps',
        surahNumber: 1,
        totalAyahs: 7,
        completedAyahs: 3,
        isDownloading: true,
      );

      expect(progress.isFullyDownloaded, false);
      expect(progress.progressFraction, closeTo(3 / 7, 0.001));
      expect(progress.progressPercent, 43);

      final completed = progress.copyWith(completedAyahs: 7, isDownloading: false);
      expect(completed.isFullyDownloaded, true);
      expect(completed.progressFraction, 1.0);
      expect(completed.progressPercent, 100);
    });
  });
}
