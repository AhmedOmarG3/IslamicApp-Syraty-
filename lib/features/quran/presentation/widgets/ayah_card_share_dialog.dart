import 'package:flutter/material.dart';
import 'package:siraty/core/widgets/islamic_share_card_dialog.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class AyahCardShareDialog {
  static void show(
    BuildContext context, {
    required String surahName,
    required int ayahNumber,
    required String verseText,
  }) {
    final cleanSurah = surahName.replaceAll('سورة', '').trim();
    final arabicAyah = QuranMetadata.toArabicDigits(ayahNumber);
    final fullSurahName = 'سورة $cleanSurah';

    IslamicShareCardDialog.show(
      context,
      type: ShareCardType.ayah,
      contentText: verseText,
      title: fullSurahName,
      subtitle: '$fullSurahName · الآية رقم $arabicAyah',
      source: 'القرآن الكريم · $fullSurahName',
    );
  }
}
