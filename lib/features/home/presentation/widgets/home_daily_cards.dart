import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/mushaf_page_service.dart';

class HomeDailyCards extends StatelessWidget {
  const HomeDailyCards({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // 1. Featured Last Read Card (كارد آخر قراءة المميز)
        Expanded(
          child: ValueListenableBuilder<LastReadModel?>(
            valueListenable: LastReadService.lastReadNotifier,
            builder: (context, lastRead, _) {
              final surahName =
                  lastRead != null ? lastRead.surahName : 'القرآن الكريم';
              final badgeLabel = lastRead != null ? 'آخر قراءة' : 'وِرد اليوم';

              final String subText;
              if (lastRead != null) {
                final pageNum = MushafPageService.getPageNumber(
                    lastRead.surahNumber, lastRead.ayahNumber);
                final pageStr = 'صفحة ${QuranMetadata.toArabicDigits(pageNum)}';
                final ayahStr =
                    'آية ${QuranMetadata.toArabicDigits(lastRead.ayahNumber)}';
                subText = '$ayahStr · $pageStr';
              } else {
                subText = 'ابدأ قراءة وِردك اليومي';
              }

              return GestureDetector(
                onTap: () async {
                  if (lastRead != null) {
                    final surah =
                        await LastReadService.loadSurah(lastRead.surahNumber);
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
                  height: 148.h,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 1. Real Photography Background: Open Holy Quran on carved wooden Rehal
                      Positioned.fill(
                        child: Image.asset(
                          AppAssets.quranCardBg,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),

                      // 2. Deep Emerald Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF09241B).withValues(alpha: 0.88),
                                      const Color(0xFF051711).withValues(alpha: 0.94),
                                    ]
                                  : [
                                      const Color(0xFF0D3326).withValues(alpha: 0.84),
                                      const Color(0xFF072118).withValues(alpha: 0.92),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header Row: Bookmark Badge & Medallion Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentGold
                                        .withValues(alpha: 0.18),
                                    border: Border.all(
                                      color: AppColors.accentGold
                                          .withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.auto_stories_rounded,
                                    size: 14.r,
                                    color: AppColors.accentGoldLight,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: AppColors.accentGold
                                          .withValues(alpha: 0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bookmark_rounded,
                                        size: 11.r,
                                        color: AppColors.accentGoldLight,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        badgeLabel,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 10.sp,
                                          color: AppColors.accentGoldLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Middle Info: Surah Name & Page/Ayah
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surahName,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.35),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  subText,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentGoldLight
                                        .withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            // Bottom Action Pill (واصل التلاوة)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accentGold
                                        .withValues(alpha: 0.28),
                                    AppColors.accentGold
                                        .withValues(alpha: 0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.accentGold
                                      .withValues(alpha: 0.45),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'واصل التلاوة',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentGoldLight,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13.r,
                                    color: AppColors.accentGoldLight,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),

        // 2. Dynamic Adhkar Card (Morning / Evening based on time)
        Expanded(
          child: Builder(
            builder: (context) {
              final currentHour = DateTime.now().hour;
              final isMorning = currentHour >= 4 && currentHour < 16;
              final adhkarTitle = isMorning ? 'أذكار الصباح' : 'أذكار المساء';
              final adhkarBadge = isMorning ? 'وِرد الصباح' : 'وِرد المساء';
              final adhkarSubtitle = isMorning ? 'حصنك وبركة يومك' : 'سكينة وطمأنينة ليلتك';
              final adhkarIcon = isMorning
                  ? Icons.wb_sunny_rounded
                  : Icons.nights_stay_rounded;


              // This card sits on a dark photographic overlay in BOTH themes,
              // so its palette is theme-independent. Deriving it from `isDark`
              // painted the light theme's dark text onto a near-black surface,
              // leaving the title effectively invisible.
              final accentColor = isMorning
                  ? AppColors.accentGoldLight
                  : const Color(0xFF9CC0E8);
              const cardTextPrimary = AppColors.textWhite;
              const cardTextMuted = Color(0xFFC3D2CB);

              final cardBorderColor = accentColor.withValues(alpha: 0.45);

              return GestureDetector(
                onTap: () => context.push('/azkar', extra: adhkarTitle),
                child: Container(
                  height: 148.h,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: cardBorderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 1. Real Photography Background: Morning Desert Dawn or Evening Mosque Twilight
                      Positioned.fill(
                        child: Image.asset(
                          isMorning ? AppAssets.morningCardBg : AppAssets.eveningCardBg,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),

                      // 2. Atmospheric Gradient Overlay
                      // Identical in both themes: the card is always a dark
                      // surface, which is what the light text is tuned for.
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isMorning
                                  ? [
                                      const Color(0xFF261A0C).withValues(alpha: 0.90),
                                      const Color(0xFF140D05).withValues(alpha: 0.95),
                                    ]
                                  : [
                                      const Color(0xFF0E1A2C).withValues(alpha: 0.90),
                                      const Color(0xFF070F1C).withValues(alpha: 0.95),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Row: Icon Medallion & Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withValues(alpha: 0.18),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    adhkarIcon,
                                    size: 14.r,
                                    color: accentColor,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMorning
                                            ? Icons.brightness_5_rounded
                                            : Icons.bedtime_rounded,
                                        size: 11.r,
                                        color: accentColor,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        adhkarBadge,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 10.sp,
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Middle Info: Title & Subtitle
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adhkarTitle,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                    color: cardTextPrimary,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  adhkarSubtitle,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: cardTextMuted,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.40),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            // Bottom Action Pill (اقرأ الأذكار)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentColor.withValues(alpha: 0.22),
                                    accentColor.withValues(alpha: 0.10),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'اقرأ الأذكار',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13.r,
                                    color: accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
