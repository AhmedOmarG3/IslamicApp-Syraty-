import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
        }
        if (state is AzanLoadedState) {
          return _LoadedPrayerCard(state: state);
        }
        if (state is AzanFailureState) {
          return const _PrayerPrompt(isError: true);
        }
        return const _PrayerPrompt();
      },
    );
  }
}

class _LoadedPrayerCard extends StatelessWidget {
  final AzanLoadedState state;

  const _LoadedPrayerCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasTimes = state.azanList.timesName.isNotEmpty &&
        state.azanList.azanTimes.isNotEmpty;
    final prayerName = hasTimes ? state.azanList.timesName.first : 'الصلاة';
    final prayerTime = hasTimes ? state.azanList.azanTimes.first : '--:--';

    return AppCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      backgroundColor: AppColors.primaryGreen,
      onTap: () => context.push('/prayer'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مواقيت الصلاة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  prayerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  prayerTime,
                  textDirection: TextDirection.ltr,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child:
                const Icon(Icons.access_time_rounded, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _PrayerPrompt extends StatelessWidget {
  final bool isError;

  const _PrayerPrompt({this.isError = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      onTap: () => context.push('/prayer'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFFCE8E6) : AppColors.accentMint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              isError ? Icons.cloud_off_rounded : Icons.access_time_rounded,
              color: isError ? AppColors.errorRed : AppColors.primaryGreen,
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isError ? 'تعذّر تحديث المواقيت' : 'مواقيت الصلاة',
                  style: AppTextStyles.titleMedium,
                ),
                AppSpacing.verticalXs,
                Text(
                  isError
                      ? 'افتح صفحة الصلاة للمحاولة مرة أخرى'
                      : 'اختر مدينتك لعرض المواقيت',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      child: const SizedBox(
        height: 72,
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Expanded(child: Text('جارٍ تحديث مواقيت الصلاة…')),
          ],
        ),
      ),
    );
  }
}
