import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeTodayPrayers extends StatelessWidget {
  const HomeTodayPrayers({super.key});

  static const List<_PrayerInfo> _prayers = [
    _PrayerInfo(name: 'الفجر', time: '٤:٣٤', isCurrent: true),
    _PrayerInfo(name: 'الظهر', time: '١:٠١', isCurrent: false),
    _PrayerInfo(name: 'العصر', time: '٤:٣٩', isCurrent: false),
    _PrayerInfo(name: 'المغرب', time: '٧:٤٩', isCurrent: false),
    _PrayerInfo(name: 'العشاء', time: '٩:١٦', isCurrent: false),
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
          // Section Title & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صلوات اليوم',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
              Text(
                '٠ من ٥',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 5 Prayers Horizontal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _prayers.map((prayer) {
              final bg = prayer.isCurrent
                  ? (isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated)
                  : (isDark ? AppColors.cardDark : AppColors.cardLight);
              final border = prayer.isCurrent
                  ? AppColors.accentGold
                  : (isDark ? AppColors.borderSubtle : AppColors.borderLight);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: border,
                      width: prayer.isCurrent ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prayer.name,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          fontWeight: prayer.isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: prayer.isCurrent
                              ? AppColors.accentGold
                              : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Circular status outline
                      Container(
                        width: 22.r,
                        height: 22.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: prayer.isCurrent
                                ? AppColors.accentGold
                                : (isDark
                                    ? AppColors.textDimmed.withValues(alpha: 0.5)
                                    : AppColors.borderLight),
                            width: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Prayer Time
                      Text(
                        prayer.time,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PrayerInfo {
  final String name;
  final String time;
  final bool isCurrent;

  const _PrayerInfo({
    required this.name,
    required this.time,
    required this.isCurrent,
  });
}
