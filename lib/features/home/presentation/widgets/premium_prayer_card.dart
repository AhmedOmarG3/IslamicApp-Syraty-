import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_card.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_cubit.dart';
import 'package:siraty/features/prayer/presentation/cubit/azan_state.dart';

class PremiumPrayerCard extends StatelessWidget {
  const PremiumPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzanCubit, AzanState>(
      builder: (context, state) {
        if (state is AzanLoadingState) {
          return const _LoadingPrayerCard();
        } else if (state is AzanLoadedState) {
          return _LoadedPrayerCard(state: state);
        } else if (state is AzanFailureState) {
          return const SizedBox();
        }
        return const SizedBox();
      },
    );
  }
}

class _LoadedPrayerCard extends StatelessWidget {
  final AzanLoadedState state;

  const _LoadedPrayerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final String nextPrayerName = state.azanList.timesName.isNotEmpty &&
            state.azanList.timesName.length > 3
        ? state.azanList.timesName[3]
        : 'المغرب';
    final String nextPrayerTime = state.azanList.azanTimes.isNotEmpty &&
            state.azanList.azanTimes.length > 3
        ? state.azanList.azanTimes[3]
        : '--:--';

    return AppCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      padding: EdgeInsets.all(24.w),
      gradientColors: const [
        AppColors.primaryGreen,
        AppColors.secondaryGreen,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصلاة القادمة',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    nextPrayerName,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.mosque_rounded,
                color: AppColors.white.withValues(alpha: 0.3),
                size: 60.sp,
              ),
            ],
          ),
          AppSpacing.verticalLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nextPrayerTime,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontFamily: 'Roboto', // For clear numbers
                  fontSize: 22.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  'متبقي 01:23:45',
                  style: AppTextStyles.caption.copyWith(color: AppColors.white),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _LoadingPrayerCard extends StatelessWidget {
  const _LoadingPrayerCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      padding: EdgeInsets.all(24.w),
      backgroundColor: AppColors.surfaceLight,
      child: SizedBox(
        height: 120.h,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
            strokeWidth: 2.w,
          ),
        ),
      ),
    );
  }
}
