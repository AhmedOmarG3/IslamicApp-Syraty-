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
    IslamicShareCardDialog.show(
      context,
      type: ShareCardType.ayah,
      contentText: verseText,
      title: surahName.startsWith('سورة') ? surahName : 'سورة $surahName',
      subtitle: 'الآية رقم ${QuranMetadata.toArabicDigits(ayahNumber)}',
      source: 'القرآن الكريم',
    );
  }
}
