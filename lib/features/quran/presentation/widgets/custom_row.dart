import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/star_number_badge.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class CustomRow extends StatelessWidget {
  const CustomRow({
    super.key,
    required this.number,
    required this.name,
    this.numberOfVerses = '',
    required this.onTap,
  });

  final VoidCallback onTap;
  final int number;
  final String name;
  final dynamic numberOfVerses;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // 1. Star Number Badge (Octagram)
                StarNumberBadge(
                  number: QuranMetadata.toArabicDigits(number),
                  size: 40.r,
                  outlineColor: isDark ? AppColors.borderGreen : AppColors.borderGold,
                  fillColor: isDark
                      ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                      : AppColors.iconBgCircleLight,
                  textColor: isDark ? AppColors.textWhite : AppColors.accentGold,
                ),
                SizedBox(width: 16.w),

                // 2. Surah Name and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${QuranMetadata.toArabicDigits(numberOfVerses)} آية',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Subtle arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
            height: 1,
            indent: 16.w,
            endIndent: 16.w,
          ),
        ],
      ),
    );
  }
}
