import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

abstract class AppDialog {
  static Future<T?> showMinimalDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'موافق',
    String? cancelText,
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryGreen),
          ),
          content: Text(
            content,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  cancelText,
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: Text(
                confirmText,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
