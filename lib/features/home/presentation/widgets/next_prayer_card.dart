import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_card.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradientColors: const [
        AppColors.primaryDark,
        AppColors.primaryGreen,
      ],
      borderRadius: AppDimensions.radiusLg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      onTap: () {
        context.push('/prayer');
      },
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Icon(
              Icons.mosque_outlined,
              size: 90,
              color: AppColors.white.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: AppColors.accentGold, size: 20),
                      AppSpacing.horizontalSm,
                      Text(
                        'الصلاة القادمة',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(color: AppColors.accentGold, width: 1),
                    ),
                    child: Text(
                      'متبقي ٠١:٢٥:٠٠',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صلاة العصر',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.white,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    '٠٣:٤٥ م',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.accentGold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
