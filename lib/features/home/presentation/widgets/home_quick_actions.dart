import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context: context,
          icon: Icons.explore_outlined,
          label: 'القبلة',
          onTap: () => context.push('/qibla'),
        ),
        _buildActionItem(
          context: context,
          icon: Icons.flare_outlined,
          label: 'السبحة',
          onTap: () => context.go('/tasbeeh'),
        ),
        _buildActionItem(
          context: context,
          icon: Icons.check_circle_outline_rounded,
          label: 'الختمة',
          onTap: () => context.push('/khatma'),
        ),
        _buildActionItem(
          context: context,
          icon: Icons.stars_outlined,
          label: 'الأسماء',
          onTap: () => context.push('/hisn-al-muslim'),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                size: 22.r,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
