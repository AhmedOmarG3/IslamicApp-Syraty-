import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';

class HijriPage extends StatelessWidget {
  const HijriPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'التقويم الهجري'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hijri Date Banner Card
            IslamicPatternCard(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              borderRadius: BorderRadius.circular(20.r),
              gradientColors: isDark
                  ? const [Color(0xFF5D9684), Color(0xFF457868)]
                  : const [Color(0xFF2E6351), Color(0xFF1E483A)],
              patternOpacity: 0.15,
              patternColor: isDark ? AppColors.bgDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              child: Column(
                children: [
                  Icon(
                    Icons.nights_stay_outlined,
                    size: 24.r,
                    color: AppColors.accentGold,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '١٥ رمضان ١٤٤٧',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'يوافق ٥ سبتمبر ٢٠٢٦م',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Calendar Month Grid Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'رمضان ١٤٤٧',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Weekdays Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج']
                        .map((d) => SizedBox(
                              width: 32.w,
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 14.h),

                  // Simplified Calendar Month Days Representation
                  _buildCalendarGrid(isDark),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            OrnamentDivider(
              starColor: AppColors.accentGold,
              lineColor: isDark ? AppColors.borderSubtle : const Color(0xFFE5DEC9),
            ),
            SizedBox(height: 12.h),

            // Month Events (مناسبات الشهر)
            Row(
              children: [
                Icon(Icons.nights_stay_outlined, color: AppColors.accentGold, size: 18.r),
                SizedBox(width: 8.w),
                Text(
                  'مناسبات الشهر',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            _buildEventTile('١', 'بداية رمضان', 'الأربعاء', isDark),
            SizedBox(height: 10.h),
            _buildEventTile('٢١', 'بدء العشر الأواخر', 'الثلاثاء', isDark),
            SizedBox(height: 10.h),
            _buildEventTile('٢٧', 'ليلة القدر (يُرجى التماسها)', 'الإثنين', isDark),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    // 30 days grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isToday = day == 15;
        final isSpecial = day == 1 || day == 21 || day == 27;

        return Container(
          margin: EdgeInsets.all(3.r),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday
                ? (isDark ? AppColors.sageGreen : const Color(0xFF2E6351))
                : Colors.transparent,
            shape: BoxShape.circle,
            border: isSpecial && !isToday
                ? Border.all(color: AppColors.accentGold, width: 1.3)
                : null,
          ),
          child: Text(
            '$day',
            style: AppTextStyles.caption.copyWith(
              color: isToday
                  ? Colors.white
                  : isSpecial
                      ? AppColors.accentGold
                      : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
              fontWeight: isToday || isSpecial ? FontWeight.bold : FontWeight.normal,
              fontSize: 12.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventTile(String day, String title, String weekday, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardHighlight : const Color(0xFFEFE7D8),
              shape: BoxShape.circle,
            ),
            child: Text(
              day,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.sageGreen : const Color(0xFF2E6351),
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Text(
            weekday,
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
