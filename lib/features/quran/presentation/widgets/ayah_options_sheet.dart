import 'package:flutter/material.dart';
import 'package:siraty/core/services/favorites_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_card_share_dialog.dart';
import 'package:siraty/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';

/// Ayah interaction sheet: tafsir, verse audio, continue playing, image
/// card share, bookmark, copy. Audio actions go through [QuranAudioCubit];
/// bookmarking is delegated to the host page via [onBookmark].
class AyahOptionsSheet extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final int versesCount;
  final int ayahNumber;
  final String verseText;

  /// Persists the bookmark and updates the host page state.
  final ValueChanged<int> onBookmark;

  const AyahOptionsSheet({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.versesCount,
    required this.ayahNumber,
    required this.verseText,
    required this.onBookmark,
  });

  static void show(
    BuildContext context, {
    required int surahNumber,
    required String surahName,
    required int versesCount,
    required int ayahNumber,
    required String verseText,
    required ValueChanged<int> onBookmark,
    VoidCallback? onDismissed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => AyahOptionsSheet(
        surahNumber: surahNumber,
        surahName: surahName,
        versesCount: versesCount,
        ayahNumber: ayahNumber,
        verseText: verseText,
        onBookmark: onBookmark,
      ),
    ).whenComplete(() => onDismissed?.call());
  }

  @override
  Widget build(BuildContext context) {
    final arabicAyah = QuranMetadata.toArabicDigits(ayahNumber);
    final formattedVerse = '﴿ $verseText ﴾ [سورة $surahName: $arabicAyah]';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        // Scrollable so long verses (e.g. 2:255) don't overflow the sheet.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah Header
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.sageGreen, width: 1),
                    ),
                    child: Text(
                      'آية $arabicAyah · سورة $surahName',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sageGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Ayah Calligraphic Text Card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.cardDarkElevated,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  '﴿ $verseText ﴾',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18.sp,
                    color: AppColors.textWhite,
                    height: 1.8,
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Action Buttons: 2 Organized Rows of 3 Pillars
              Row(
                children: [
                  // 1. Tafsir
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.auto_stories_rounded,
                      label: 'تفسير الآية',
                      onTap: () {
                        Navigator.pop(context);
                        TafsirBottomSheet.show(
                          context,
                          surahNumber: surahNumber,
                          surahName: surahName,
                          ayahNumber: ayahNumber,
                          verseText: verseText,
                        );
                      },
                    ),
                  ),

                  // 2. Play Single Verse Audio (استماع للآية منفردة)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.volume_up_rounded,
                      label: 'استماع للآية',
                      onTap: () {
                        Navigator.pop(context);
                        context.read<QuranAudioCubit>().playAyah(
                              surahNum: surahNumber,
                              ayahNum: ayahNumber,
                              surahName: surahName,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'جارٍ تلاوة الآية $arabicAyah بصوت ${context.read<QuranAudioCubit>().state.selectedReciter.name}',
                              style: TextStyle(
                                  fontFamily: 'Amiri', fontSize: 13.sp),
                            ),
                            backgroundColor: AppColors.cardHighlight,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),

                  // 3. Continue Playing from this Ayah
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.playlist_play_rounded,
                      label: 'المتابعة من هنا',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/quran-listen', extra: {
                          'surahNumber': surahNumber,
                          'surahName': surahName,
                          'versesCount': versesCount,
                          'initialAyah': ayahNumber,
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 4. Share as Islamic Image Card
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'بطاقة الآية',
                      onTap: () {
                        Navigator.pop(context);
                        AyahCardShareDialog.show(
                          context,
                          surahName: surahName,
                          ayahNumber: ayahNumber,
                          verseText: verseText,
                        );
                      },
                    ),
                  ),

                  // 5. Bookmark as Last Read (حفظ كعلامة القراءة)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.bookmark_add_rounded,
                      label: 'علامة القراءة',
                      onTap: () {
                        onBookmark(ayahNumber);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم حفظ الآية $arabicAyah من سورة $surahName كآخر قراءة',
                              style: TextStyle(
                                  fontFamily: 'Amiri', fontSize: 13.sp),
                            ),
                            backgroundColor: AppColors.accentGold,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                  // 6. Add to Favorites (إضافة للمفضلة)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.favorite_border_rounded,
                      label: 'المفضلة',
                      onTap: () async {
                        // Create FavoriteItem and toggle
                        final item = FavoriteItem(
                          id: '${surahNumber}_$ayahNumber',
                          type: FavoriteType.ayah,
                          title: surahName,
                          subtitle: 'آية $arabicAyah',
                          content: verseText,
                        );
                        await FavoritesService.instance.toggleFavorite(item);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تمت إضافة الآية إلى المفضلة',
                              style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
                            ),
                            backgroundColor: AppColors.accentGold,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  // 7. Copy Formatted Verse (نسخ النص)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.copy_rounded,
                      label: 'نسخ الآية',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: formattedVerse));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم نسخ الآية الكريمة ومصدرها إلى الحافظة',
                              style: TextStyle(
                                  fontFamily: 'Amiri', fontSize: 13.sp),
                            ),
                            backgroundColor: AppColors.cardHighlight,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.cardDarkElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 20.r),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 11.sp,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
