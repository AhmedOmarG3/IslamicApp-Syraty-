import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';
import 'package:siraty/features/prayer/domain/entities/prayer_time.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_state.dart';

class HomeHeaderBanner extends StatelessWidget {
  const HomeHeaderBanner({super.key});

  static String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  static String _formatTime(DateTime time) {
    return _toArabicDigits(DateFormat('hh:mm').format(time));
  }

  static String _formatCountdownText(Duration? countdown) {
    if (countdown == null) return 'حان موعد الصلاة';
    final totalMinutes = countdown.inMinutes;
    if (totalMinutes <= 0) return 'حان موعد الصلاة الآن';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return 'بعد ${_toArabicDigits(hours.toString())} ساعة و ${_toArabicDigits(mins.toString())} دقيقة';
    } else {
      return 'بعد ${_toArabicDigits(mins.toString())} دقيقة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IslamicPatternCard(
      width: double.infinity,
      borderRadius: BorderRadius.circular(24.r),
      cellSize: 52.0,
      gradientColors: isDark
          ? null
          : const [
              Color(0xFF265443),
              Color(0xFF1E4536),
              Color(0xFF17382B),
            ],
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: const Color(0xFF1B4436).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      child: BlocBuilder<AzanCubit, AzanState>(
        builder: (context, state) {
          String cityName = 'القاهرة';
          String prayerTitle = 'الفجر  ٠٤:٣٤';
          String countdownText = 'مواقيت الصلاة';

          if (state is AzanLoadedState) {
            cityName = state.snapshot.location.cityName;
            final nextPrayer = state.nextPrayer?.prayer ??
                state.snapshot.tomorrow.getTime(PrayerType.fajr);

            if (nextPrayer != null) {
              prayerTitle = '${nextPrayer.arabicName}  ${_formatTime(nextPrayer.time)}';
              countdownText = _formatCountdownText(state.countdown);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Greeting, App Title, and Location Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قيامًا مباركًا',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.sageGreen,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'سِيرتي',
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Dynamic Location Pill Badge (Tapping opens Location Picker)
                  InkWell(
                    onTap: () => context.push('/prayer-location'),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F4839).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF2E634F), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.r,
                            color: AppColors.accentGold,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            cityName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textWhite,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Next Prayer Indicator
              Row(
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: const BoxDecoration(
                      color: AppColors.sageGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'الصلاة القادمة',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.sageGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // Prayer Name & Countdown Row with "All Times" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayerTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        countdownText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.sageGreen.withValues(alpha: 0.85),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.go('/prayer'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardHighlight,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                      ),
                      child: Text(
                        'كل المواقيت',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
