import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/prayer_scheduler_interface.dart';

class AutostartGuideDialog extends StatelessWidget {
  final String manufacturer;
  final PrayerSchedulerInterface scheduler;
  final VoidCallback? onDismiss;

  const AutostartGuideDialog({
    super.key,
    required this.manufacturer,
    required this.scheduler,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required String manufacturer,
    required PrayerSchedulerInterface scheduler,
    VoidCallback? onDismiss,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AutostartGuideDialog(
        manufacturer: manufacturer,
        scheduler: scheduler,
        onDismiss: onDismiss,
      ),
    );
  }

  String _getManufacturerSpecificTip() {
    final m = manufacturer.toLowerCase();
    if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
      return 'في هواتف شاومي (Xiaomi / Redmi / POCO):\n'
          '١. فعّل خيار «بدء التشغيل التلقائي / Autostart» لسيرتي.\n'
          '٢. اضبط موفر البطارية على «لا توجد قيود / No restrictions».';
    } else if (m.contains('oppo') || m.contains('realme')) {
      return 'في هواتف أوبو وريلمي (Oppo / Realme):\n'
          '١. اسمح بـ «بدء التشغيل التلقائي / Auto-launch».\n'
          '٢. اسمح بـ «التشغيل في الخلفية» لسيرتي.';
    } else if (m.contains('huawei') || m.contains('honor')) {
      return 'في هواتف هواوي وهونر (Huawei / Honor):\n'
          '١. ادخل على «إدارة بدء التشغيل / App launch».\n'
          '٢. أوقف الإدارة التلقائية لسيرتي، وفعّل «بدء التشغيل والتشغيل في الخلفية».';
    } else if (m.contains('vivo') || m.contains('iqoo')) {
      return 'في هواتف فيفو (Vivo / iQOO):\n'
          '١. فعّل «التشغيل التلقائي / Autostart» لسيرتي في إدارة الأذونات.';
    } else if (m.contains('samsung')) {
      return 'في هواتف سامسونج (Samsung):\n'
          '١. استثنِ سيرتي من «التطبيقات في وضع السكون / Sleeping apps».\n'
          '٢. اضبط استخدام البطارية على «غير مقيّد / Unrestricted».';
    } else if (m.contains('transsion') ||
        m.contains('infinix') ||
        m.contains('tecno') ||
        m.contains('itel')) {
      return 'في هواتف إنفينيكس وتكنو (Infinix / Tecno):\n'
          '١. فعّل «بدء التشغيل التلقائي / Auto-start» لسيرتي في إدارة الهاتف.';
    }
    return 'يرجى تفعيل «بدء التشغيل التلقائي / Autostart» واستثناء سيرتي من توفير البطارية لضمان دقة الأذان والشاشة مقفلة.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: const BorderSide(color: AppColors.borderGold, width: 1.2),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon header
            Container(
              width: 58.r,
              height: 58.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.cardHighlight
                    : AppColors.iconBgCircleLight,
                border: Border.all(color: AppColors.accentGold, width: 1.5),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: AppColors.accentGold,
                size: 32.r,
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'بدء التشغيل التلقائي (Autostart)',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.5.sp,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'خطوة هامة جداً لضمان انطلاق صوت الأذان في موعده الدقيق حتى عند إغلاق التطبيق وقفل الشاشة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.5.sp,
                height: 1.5,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
              ),
            ),
            SizedBox(height: 16.h),

            // Manufacturer instructions box
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLightElevated,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? AppColors.cardHighlight : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Text(
                _getManufacturerSpecificTip(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12.sp,
                  height: 1.6,
                  color: isDark ? AppColors.textMuted : AppColors.textDarkPrimary,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Primary Button: Open Settings Now
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: const BorderSide(
                        color: AppColors.accentGold, width: 1),
                  ),
                ),
                onPressed: () async {
                  await scheduler.openAutoStartSettings();
                },
                icon: Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                  size: 18.r,
                ),
                label: Text(
                  'فتح شاشة التفعيل الآن',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Secondary Button: Done / Dismiss
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              child: Text(
                'حسناً، قمت بالتفعيل',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
