import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeStreakTracker extends StatelessWidget {
  const HomeStreakTracker({super.key});

  static const List<_DayStreak> _days = [
    _DayStreak(dayName: 'الس', count: '3', isFull: false),
    _DayStreak(dayName: 'الج', count: '5', isFull: true),
    _DayStreak(dayName: 'الخ', count: '5', isFull: true),
    _DayStreak(dayName: 'الأ', count: '4', isFull: false),
    _DayStreak(dayName: 'الث', count: '5', isFull: true),
    _DayStreak(dayName: 'الا', count: '5', isFull: true),
    _DayStreak(dayName: 'الأ', count: '5', isFull: true),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header: Streak Number + Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '١٢',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'يومًا متتابعًا',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14.sp,
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'التفاصيل',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 7 Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((d) {
              return Column(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: d.isFull
                          ? AppColors.sageGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: d.isFull
                            ? AppColors.sageGreen
                            : AppColors.accentGold,
                        width: 1.3,
                      ),
                    ),
                    child: Text(
                      d.count,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: d.isFull
                            ? (isDark ? AppColors.bgDark : Colors.white)
                            : AppColors.accentGold,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    d.dayName,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayStreak {
  final String dayName;
  final String count;
  final bool isFull;

  const _DayStreak({
    required this.dayName,
    required this.count,
    required this.isFull,
  });
}
