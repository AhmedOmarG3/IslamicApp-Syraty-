import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_button.dart';

class AppErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.errorRed,
            ),
            AppSpacing.verticalLg,
            Text(
              'حدث خطأ',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.errorRed,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalLg,
              AppButton(
                label: 'إعادة المحاولة',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                type: AppButtonType.outlined,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
