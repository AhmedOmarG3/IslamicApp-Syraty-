import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../../../core/widgets/ornament_divider.dart';
import '../../domain/entities/prayer_time.dart';
import '../cubit/azan_cubit.dart';
import '../cubit/azan_state.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  IconData _getPrayerIcon(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.brightness_5_rounded;
      case PrayerType.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerType.isha:
        return Icons.nights_stay_rounded;
    }
  }

  String _formatPrayerTime(DateTime time) {
    return DateFormat('hh:mm a', 'ar').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'مواقيت الصلاة',
        showBackButton: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      body: BlocBuilder<AzanCubit, AzanState>(
        builder: (context, state) {
          if (state is AzanLoadingState || state is AzanInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }

          if (state is AzanFailureState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textDarkPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AzanCubit>().loadPrayerTimes(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: const Text('إعادة المحاولة',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final loaded = state as AzanLoadedState;
          final location = loaded.derivedToday.location;
          final times = loaded.derivedToday.times;
          final nextPrayerKey = loaded.nextPrayer?.prayer.key;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                // City / Location Selection Bar
                InkWell(
                  onTap: () => context.push('/prayer-location'),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : AppColors.borderLight,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.15 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.accentGold,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${location.cityName} ${location.countryName.isNotEmpty ? "(${location.countryName})" : ""}',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDarkPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5.sp,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'تغيير يدويًا',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.sageGreen
                                : const Color(0xFF4A7D6E),
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Auto location hint
                InkWell(
                  onTap: () => context.read<AzanCubit>().autoDetectLocation(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        color: isDark
                            ? AppColors.textDimmed
                            : const Color(0xFF7F8E87),
                        size: 13.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'اضغط لتحديد موقعك تلقائيًا (GPS)',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textDimmed
                              : const Color(0xFF7F8E87),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Prayer Cards List
                Builder(builder: (context) {
                  final hasCurrent =
                      times.any((t) => t.status == PrayerStatus.current);
                  return Column(
                    children: times.map((p) {
                      final isCurrent = p.status == PrayerStatus.current;
                      final isNext = (nextPrayerKey == p.key) && !hasCurrent;

                      final cardBg = (isNext || isCurrent)
                          ? (isDark
                              ? AppColors.cardDarkElevated
                              : const Color(0xFFF7F2E7))
                          : (isDark ? AppColors.cardDark : AppColors.cardLight);

                      final cardBorder = (isNext || isCurrent)
                          ? (isDark
                              ? AppColors.borderGold
                              : const Color(0xFFD6BE97))
                          : (isDark
                              ? AppColors.borderSubtle
                              : AppColors.borderLight);

                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: cardBorder,
                            width: (isNext || isCurrent) ? 1.3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.15 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon in Circle
                            Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardHighlight
                                    : const Color(0xFFEFE7D8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getPrayerIcon(p.key),
                                color: (isNext || isCurrent)
                                    ? (isDark
                                        ? AppColors.accentGold
                                        : const Color(0xFFA27C44))
                                    : (isDark
                                        ? AppColors.sageGreen
                                        : const Color(0xFF6F887C)),
                                size: 20.r,
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Prayer Name
                            Text(
                              p.arabicName,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDarkPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // "التالية بعد..." badge if active
                            if (isNext) ...[
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.accentGold
                                          .withValues(alpha: 0.25)
                                      : const Color(0xFFA27C44),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: isDark
                                      ? Border.all(
                                          color: AppColors.accentGold,
                                          width: 0.8)
                                      : null,
                                ),
                                child: Text(
                                  'التالية بعد ${loaded.formattedCountdown}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? AppColors.accentGold
                                        : Colors.white,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else if (isCurrent) ...[
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'حان وقتها',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryGreen,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],

                            const Spacer(),

                            // Prayer Time
                            Text(
                              _formatPrayerTime(p.time),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDarkPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.5.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 12.h),

                OrnamentDivider(
                  starColor: AppColors.accentGold,
                  lineColor:
                      isDark ? AppColors.borderSubtle : const Color(0xFFE5DEC9),
                ),
                SizedBox(height: 12.h),

                // Sub-feature Action Card: اتجاه القبلة
                GestureDetector(
                  onTap: () => context.push('/qibla'),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : AppColors.borderLight,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.15 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardHighlight
                                : const Color(0xFFEFE7D8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.explore_outlined,
                            color: isDark
                                ? AppColors.sageGreen
                                : const Color(0xFF2E6351),
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اتجاه القبلة الشريفة',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textDarkPrimary,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'بوصلة تفاعلية حيّة لتحديد اتجاه الكعبة المشرفة بدقة',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.textDimmed
                                      : const Color(0xFF7F8E87),
                                  fontSize: 11.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.r,
                          color: isDark
                              ? AppColors.accentGoldLight
                              : AppColors.sageGreenDark,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
