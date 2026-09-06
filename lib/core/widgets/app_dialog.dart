import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class AppDialog {
  static void show({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalMd,
                content,
                if (actions != null) ...[
                  AppSpacing.verticalLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
