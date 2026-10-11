import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

enum SnackBarType { success, error, info }

/// Premium Islamic floating SnackBar with distinct colors, high contrast,
/// and clear iconography. Replaces primitive, hard-to-read default SnackBars.
class AppSnackBar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    String? title,
    required SnackBarType type,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final Color bgColor;
    final Color borderColor;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = const Color(0xFF0F241C);
        borderColor = AppColors.emeraldGreen;
        iconColor = AppColors.emeraldGreen;
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        bgColor = const Color(0xFF2C1113);
        borderColor = const Color(0xFFE74C3C);
        iconColor = const Color(0xFFFF6B6B);
        icon = Icons.error_outline_rounded;
        break;
      case SnackBarType.info:
        bgColor = const Color(0xFF162520);
        borderColor = AppColors.accentGold;
        iconColor = AppColors.accentGold;
        icon = Icons.info_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      duration: duration,
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 12.sp,
                      color: const Color(0xFFF0F4F2),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    messenger.showSnackBar(snackBar);
  }
}
