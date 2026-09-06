import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 56,
                color: AppColors.textSecondary,
              ),
              AppSpacing.verticalLg,
            ],
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.verticalSm,
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
