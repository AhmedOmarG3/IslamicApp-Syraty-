import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/islamic_ornament_painter.dart';

import 'package:siraty/features/home/domain/services/daily_ayah_service.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/presentation/widgets/ayah_card_share_dialog.dart';
import 'package:siraty/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';

class HomeDailyAyah extends StatelessWidget {
  const HomeDailyAyah({super.key});

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDarkElevated
              : const Color(0xFFFBF8F2),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.45),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.r,
              color: AppColors.accentGold,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyAyah = DailyAyahService.getDailyAyah();
    final arabicAyah = QuranMetadata.toArabicDigits(dailyAyah.ayahNumber);

    // Adaptive responsive font sizing based on length of the verse
    final textLen = dailyAyah.verseText.length;
    final double ayahFontSize = textLen > 160
        ? 16.sp
        : textLen > 70
            ? 18.sp
            : 21.sp;

    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF163E32),
              Color(0xFF0F2B22),
              Color(0xFF091C16),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFCF8EE),
              Color(0xFFF7EEDC),
              Color(0xFFF0E3CB),
            ],
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomPaint(
        painter: IslamicOrnamentPainter(
          primaryGold: AppColors.accentGold.withValues(alpha: isDark ? 0.65 : 0.75),
          borderWidth: 1.1,
          cornerSize: 20.r,
          showCornerFlourishes: true,
          showInnerBorder: true,
          showArch: true,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 14.h),

              // Ayah Text in Calligraphic AmiriQuran
              Text(
                '﴿ ${dailyAyah.verseText} ﴾',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: ayahFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.85,
                  color: isDark ? const Color(0xFFFBF8F0) : const Color(0xFF1E1710),
                ),
              ),

              SizedBox(height: 12.h),

              // Reference Badge (سورة ... · آية ...)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDarkElevated
                      : const Color(0xFFEFE5D2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: isDark ? 0.3 : 0.45),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'سورة ${dailyAyah.surahName} · آية $arabicAyah',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12.sp,
                    color: isDark ? AppColors.accentGoldLight : const Color(0xFF8C661D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Rosette Divider
              IslamicRosetteDivider(
                goldColor: AppColors.accentGold.withValues(alpha: isDark ? 0.45 : 0.6),
                height: 14.h,
              ),

              SizedBox(height: 14.h),

              // 4 Action Pillars: Read, Listen, Tafsir, Share
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickAction(
                    icon: Icons.menu_book_rounded,
                    label: 'قراءة',
                    isDark: isDark,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final surah = await LastReadService.loadSurah(dailyAyah.surahNumber);
                      if (context.mounted && surah != null) {
                        context.push('/surah-details', extra: {
                          'surah': surah,
                          'surahName': dailyAyah.surahName,
                          'targetAyah': dailyAyah.ayahNumber,
                        });
                      }
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.volume_up_rounded,
                    label: 'استماع',
                    isDark: isDark,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final surah = await LastReadService.loadSurah(dailyAyah.surahNumber);
                      final versesCount = surah?.verses.length ?? 0;
                      if (context.mounted && surah != null && versesCount > 0) {
                        context.push(
                          '/quran-listen',
                          extra: {
                            'surahNumber': dailyAyah.surahNumber,
                            'surahName': dailyAyah.surahName,
                            'versesCount': versesCount,
                            'initialAyah': dailyAyah.ayahNumber,
                          },
                        );
                      }
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.auto_stories_rounded,
                    label: 'تفسير',
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      TafsirBottomSheet.show(
                        context,
                        surahNumber: dailyAyah.surahNumber,
                        surahName: dailyAyah.surahName,
                        ayahNumber: dailyAyah.ayahNumber,
                        verseText: dailyAyah.verseText,
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.photo_library_rounded,
                    label: 'مشاركة',
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AyahCardShareDialog.show(
                        context,
                        surahName: dailyAyah.surahName,
                        ayahNumber: dailyAyah.ayahNumber,
                        verseText: dailyAyah.verseText,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
