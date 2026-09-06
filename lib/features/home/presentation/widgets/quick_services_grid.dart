import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class QuickServicesGrid extends StatelessWidget {
  const QuickServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخدمات السريعة',
            style: AppTextStyles.titleMedium,
          ),
          AppSpacing.verticalMd,
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  title: 'القرآن',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.primaryGreen,
                  onTap: () => context.push('/quran'),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: _ServiceCard(
                  title: 'الأذكار',
                  icon: Icons.brightness_6_rounded,
                  color: const Color(0xFFE67E22), // Warm orange
                  onTap: () => context.push('/azkar'),
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  title: 'المسبحة',
                  icon: Icons.touch_app_rounded,
                  color: AppColors.accentGold,
                  onTap: () => context.push('/tasbeeh'),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: _ServiceCard(
                  title: 'الصلوات',
                  icon: Icons.access_time_rounded,
                  color: AppColors.secondaryGreen,
                  onTap: () => context.push('/prayer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
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
