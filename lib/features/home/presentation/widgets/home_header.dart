import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'السلام عليكم ورحمة الله وبركاته',
                style: AppTextStyles.titleMedium,
              ),
              AppSpacing.verticalXs,
              Text(
                'الأربعاء، ١٥ صفر ١٤٤٨ هـ  |  ٥ أغسطس ٢٠٢٦ م',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            radius: 22,
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
