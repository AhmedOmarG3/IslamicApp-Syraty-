import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';

class HomeDailyAyah extends StatelessWidget {
  const HomeDailyAyah({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildCardContent() {
      return Column(
        children: [
          // Golden 8-pointed star icon
          Icon(
            Icons.flare_rounded,
            size: 22.r,
            color: AppColors.accentGold,
          ),
          SizedBox(height: 6.h),

          // "آية اليوم"
          Text(
            'آية اليوم',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
            ),
          ),
          SizedBox(height: 12.h),

          // Ayah in Ornate Calligraphy
          Text(
            '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
            textAlign: TextAlign.center,
            style: AppTextStyles.ayahText.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 10.h),

          // Reference Surah & Ayah
          Text(
            'طه · ١١٤',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: AppColors.accentGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!isDark) {
      // Light Mode: Warm, gentle, luxurious ivory card with subtle golden border
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.borderGold.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGold.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: buildCardContent(),
      );
    }

    // Dark Mode: Deep Emerald Pattern Card
    return IslamicPatternCard(
      width: double.infinity,
      borderRadius: BorderRadius.circular(22.r),
      cellSize: 48.0,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      child: buildCardContent(),
    );
  }
}
