import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/services/haptic_service.dart';

class HapticSettingsSheet extends StatelessWidget {
  final HapticService hapticService;
  final VoidCallback onUpdated;

  const HapticSettingsSheet({
    super.key,
    required this.hapticService,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required HapticService hapticService,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => HapticSettingsSheet(
        hapticService: hapticService,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [
      (
        HapticStrength.off,
        'معطّل (بدون اهتزاز)',
        'تسبيح وأذكار صامتة تماماً',
        Icons.vibration_outlined,
      ),
      (
        HapticStrength.light,
        'خفيف (الافتراضي)',
        'نبضة ناعمة ومريحة مع التكرار السريع',
        Icons.touch_app_outlined,
      ),
      (
        HapticStrength.medium,
        'متوسط',
        'نبضة واضحة ومتوازنة مع كل ضغطة',
        Icons.vibration,
      ),
      (
        HapticStrength.heavy,
        'قوي',
        'نبضة قوية ومؤكدة لكل تسبيحة',
        Icons.edgesensor_high_rounded,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.textDimmed : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'قوة اهتزاز زر الأذكار والسبحة',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'اختر المستوى الأنسب لك (ستشعر بنبضة تجريبية عند الاختيار):',
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
            ),
          ),
          SizedBox(height: 14.h),
          ...options.map((opt) {
            final isSelected = hapticService.strength == opt.$1;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.accentGold
                        : (isDark ? AppColors.cardDark : AppColors.borderLight),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                tileColor: isSelected
                    ? (isDark
                        ? AppColors.accentGold.withValues(alpha: 0.15)
                        : AppColors.accentGold.withValues(alpha: 0.08))
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                leading: Icon(
                  opt.$4,
                  color: isSelected ? AppColors.accentGold : AppColors.sageGreen,
                ),
                title: Text(
                  opt.$2,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  ),
                ),
                subtitle: Text(
                  opt.$3,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                    fontSize: 11.5.sp,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                    : null,
                onTap: () async {
                  await hapticService.setStrength(opt.$1);
                  onUpdated();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
