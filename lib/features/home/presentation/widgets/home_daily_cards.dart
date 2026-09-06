import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';

class HomeDailyCards extends StatelessWidget {
  const HomeDailyCards({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranCardBg = isDark ? AppColors.sageGreen : const Color(0xFF2E6351);
    final quranTextColor = isDark ? AppColors.bgDark : AppColors.white;
    final quranBadgeBg = isDark ? AppColors.bgDark.withValues(alpha: 0.12) : const Color(0xFF234F40);
    final quranBadgeText = isDark ? AppColors.bgDark : AppColors.accentGoldLight;

    final adhkarCardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final adhkarBorder = isDark ? AppColors.borderSubtle : AppColors.borderLight;
    final adhkarTextColor = isDark ? AppColors.textWhite : AppColors.textDarkPrimary;
    final adhkarSubtitleColor = isDark ? AppColors.textMuted : AppColors.textDarkMuted;
    final inactiveSegmentColor = isDark ? AppColors.cardHighlight : const Color(0xFFEADBCE);

    return Row(
      children: [
        // 1. Quran Daily Routine Card (Sage Green / Deep Emerald in Light mode)
        Expanded(
          child: ValueListenableBuilder<LastReadModel?>(
            valueListenable: LastReadService.lastReadNotifier,
            builder: (context, lastRead, _) {
              final surahName = lastRead != null ? lastRead.surahName : 'القرآن الكريم';
              final ayahText = lastRead != null
                  ? 'آية ${QuranMetadata.toArabicDigits(lastRead.ayahNumber)}'
                  : 'ابدأ القراءة';
              final badgeLabel = lastRead != null ? 'آخر قراءة' : 'وِرد اليوم';

              return GestureDetector(
                onTap: () async {
                  if (lastRead != null) {
                    final surah = await LastReadService.loadSurah(lastRead.surahNumber);
                    if (surah != null && context.mounted) {
                      context.push(
                        '/surah-details',
                        extra: {
                          'surah': surah,
                          'surahName': lastRead.surahName,
                          'targetAyah': lastRead.ayahNumber,
                        },
                      );
                      return;
                    }
                  }
                  if (context.mounted) {
                    context.go('/quran');
                  }
                },
                child: Container(
                  height: 140.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: quranCardBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark ? Colors.transparent : const Color(0xFF285443),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.sageGreen.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            lastRead != null
                                ? Icons.bookmark_added_rounded
                                : Icons.menu_book_rounded,
                            size: 20.r,
                            color: quranTextColor,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: quranBadgeBg,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              badgeLabel,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10.sp,
                                color: quranBadgeText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surahName,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: quranTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            ayahText,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: quranTextColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      // Action Row: Click to continue
                      Row(
                        children: [
                          Text(
                            'متابعة التلاوة',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: quranTextColor,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14.r,
                            color: quranTextColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),

        // 2. Evening Adhkar Card
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/azkar'),
            child: Container(
              height: 140.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: adhkarCardBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: adhkarBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.nights_stay_outlined,
                        size: 20.r,
                        color: AppColors.accentGold,
                      ),
                      Text(
                        'وقت المساء',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          color: adhkarSubtitleColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'أذكار المساء',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: adhkarTextColor,
                    ),
                  ),
                  // 4 Segment Progress Row
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? AppColors.accentGold
                                : inactiveSegmentColor,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
