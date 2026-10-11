import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class CustomZekrRow extends StatelessWidget {
  const CustomZekrRow({
    super.key,
    required this.number,
    required this.name,
    required this.onTap,
    this.count,
  });

  final VoidCallback onTap;
  final int number;
  final String name;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Index & Repetition pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        QuranMetadata.toArabicDigits(number),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                        ),
                      ),
                    ),
                    if (count != null && count! > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardHighlight : const Color(0xFFF3EFE8),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'التكرار: ${QuranMetadata.toArabicDigits(count!)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Zekr Text: Clear, open, readable Arabic typography
                Text(
                  name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16.5.sp,
                    height: 1.95,
                    letterSpacing: 0.15,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1A2621),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
