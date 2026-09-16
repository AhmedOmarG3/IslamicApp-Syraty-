import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/islamic_ornament_painter.dart';
import '../../../prayer/domain/entities/prayer_time.dart';
import '../../../prayer/presentation/cubit/azan_cubit.dart';
import '../../../prayer/presentation/cubit/azan_state.dart';

class HomeTodayPrayers extends StatelessWidget {
  const HomeTodayPrayers({super.key});

  static String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AzanCubit, AzanState>(
      builder: (context, state) {
        if (state is! AzanLoadedState) {
          return const SizedBox.shrink();
        }

        // Filter out sunrise so we only show the 5 obligatory prayers
        final prayers = state.derivedToday.times
            .where((t) => t.key != PrayerType.sunrise)
            .toList();

        final currentPrayer = prayers.where((p) => p.status == PrayerStatus.current).firstOrNull;
        final nextPrayer = state.nextPrayer?.prayer;
        final nextPrayerKey = nextPrayer?.key;

        final String headerBadgeText;
        final Color headerBadgeBg;
        final Color headerBadgeBorder;
        final Color headerBadgeTextColor;

        if (currentPrayer != null) {
          headerBadgeText = 'وقت صلاة ${currentPrayer.arabicName} الآن';
          headerBadgeBg = AppColors.accentGold.withValues(alpha: isDark ? 0.2 : 0.12);
          headerBadgeBorder = AppColors.accentGold.withValues(alpha: 0.4);
          headerBadgeTextColor = isDark ? AppColors.accentGoldLight : const Color(0xFF9A7424);
        } else if (nextPrayer != null) {
          headerBadgeText = 'الصلاة القادمة: ${nextPrayer.arabicName}';
          headerBadgeBg = AppColors.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1);
          headerBadgeBorder = AppColors.primaryGreen.withValues(alpha: 0.35);
          headerBadgeTextColor = isDark ? AppColors.accentGoldLight : AppColors.primaryGreen;
        } else {
          headerBadgeText = 'انقضت صلوات اليوم';
          headerBadgeBg = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
          headerBadgeBorder = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12);
          headerBadgeTextColor = isDark ? AppColors.textDimmed : AppColors.textDarkSecondary;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            painter: IslamicOrnamentPainter(
              primaryGold: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.45),
              borderWidth: 1.0,
              cornerSize: 14.r,
              showCornerFlourishes: true,
              showInnerBorder: true,
              showArch: false,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mosque_rounded,
                            size: 16.r,
                            color: AppColors.accentGold,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'مواقيت صلوات اليوم',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
                        decoration: BoxDecoration(
                          color: headerBadgeBg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: headerBadgeBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          headerBadgeText,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: headerBadgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // 5 Prayers Responsive Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final hasCurrent = prayers.any((p) => p.status == PrayerStatus.current);
                      // Calculate dynamic gap based on width
                      final gap = (constraints.maxWidth > 350) ? 6.w : 3.w;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: prayers.map((prayer) {
                          final isCurrent = prayer.status == PrayerStatus.current;
                          final isNext = (nextPrayerKey == prayer.key) && !hasCurrent;
                          final isPassed = prayer.status == PrayerStatus.passed;
                          final isActive = isCurrent || isNext;

                          final cardBg = isCurrent
                              ? (isDark
                                  ? AppColors.cardDarkElevated
                                  : const Color(0xFFFBF6EC))
                              : isNext
                                  ? (isDark
                                      ? const Color(0xFF1B2C24)
                                      : const Color(0xFFEFF5F0))
                                  : isPassed
                                      ? (isDark
                                          ? const Color(0xFF0F1612)
                                          : const Color(0xFFF7F8F7))
                                      : (isDark
                                          ? const Color(0xFF131B17)
                                          : const Color(0xFFFAFBF9));

                          final border = isCurrent
                              ? AppColors.accentGold
                              : isNext
                                  ? AppColors.primaryGreen
                                  : isPassed
                                      ? (isDark
                                          ? const Color(0x1AFFFFFF)
                                          : const Color(0x12000000))
                                      : (isDark ? AppColors.borderSubtle : AppColors.borderLight);

                          final nameColor = isCurrent
                              ? AppColors.accentGold
                              : isNext
                                  ? (isDark ? AppColors.accentGoldLight : AppColors.primaryGreen)
                                  : isPassed
                                      ? (isDark ? const Color(0xFF758680) : const Color(0xFF8C9B94))
                                      : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary);

                          final timeColor = isCurrent
                              ? AppColors.accentGold
                              : isNext
                                  ? (isDark ? AppColors.textWhite : AppColors.textDarkPrimary)
                                  : isPassed
                                      ? (isDark ? const Color(0xFF5A6B65) : const Color(0xFFA0AEA8))
                                      : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary);

                          final formattedTime = _toArabicDigits(
                            DateFormat('hh:mm').format(prayer.time),
                          );

                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: gap / 2),
                              padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 2.w),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: border,
                                  width: isActive ? 1.4 : 0.8,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accentGold.withValues(alpha: isDark ? 0.25 : 0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Prayer Name (Fitted to prevent overflow)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      prayer.arabicName,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 12.sp,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                        color: nameColor,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 6.h),

                                  // Timeline Status Indicator
                                  Container(
                                    width: 22.r,
                                    height: 22.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent
                                          ? AppColors.accentGold.withValues(alpha: isDark ? 0.25 : 0.18)
                                          : isNext
                                              ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.15)
                                              : isPassed
                                                  ? (isDark ? const Color(0x14FFFFFF) : const Color(0x0C000000))
                                                  : (isDark
                                                      ? AppColors.cardHighlight
                                                      : Colors.grey.withValues(alpha: 0.1)),
                                      border: Border.all(
                                        color: isCurrent
                                            ? AppColors.accentGold
                                            : isNext
                                                ? AppColors.primaryGreen
                                                : isPassed
                                                    ? (isDark
                                                        ? const Color(0x28FFFFFF)
                                                        : const Color(0x1E000000))
                                                    : (isDark
                                                        ? AppColors.textDimmed.withValues(alpha: 0.4)
                                                        : AppColors.borderLight),
                                        width: isActive ? 1.4 : 0.9,
                                      ),
                                    ),
                                    child: Center(
                                      child: isCurrent
                                          ? Container(
                                              width: 7.r,
                                              height: 7.r,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.accentGold,
                                              ),
                                            )
                                          : isNext
                                              ? Container(
                                                  width: 6.r,
                                                  height: 6.r,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isDark ? AppColors.accentGoldLight : AppColors.primaryGreen,
                                                  ),
                                                )
                                              : isPassed
                                                  ? Container(
                                                      width: 4.r,
                                                      height: 4.r,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isDark ? const Color(0xFF556860) : const Color(0xFFB0BEB8),
                                                      ),
                                                    )
                                                  : null,
                                    ),
                                  ),

                                  SizedBox(height: 6.h),

                                  // Prayer Time (Fitted to prevent clipping)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 11.5.sp,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        color: timeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
