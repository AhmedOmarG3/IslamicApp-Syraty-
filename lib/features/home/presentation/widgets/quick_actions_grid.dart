import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'القرآن الكريم',
        'icon': AppAssets.quranIcon,
        'route': '/quran',
        'color': AppColors.cardQuranGreen,
      },
      {
        'title': 'الأذكار اليومية',
        'icon': AppAssets.azkarIcon,
        'route': '/azkar',
        'color': AppColors.cardSebhaBlue,
      },
      {
        'title': 'مواقيت الصلاة',
        'icon': AppAssets.prayingIcon,
        'route': '/prayer',
        'color': AppColors.cardQuranGreen,
      },
      {
        'title': 'السبحة الإلكترونية',
        'icon': AppAssets.tasbeehIcon,
        'route': '/tasbeeh',
        'color': AppColors.cardSebhaBlue,
      },
      {
        'title': 'اتجاه القبلة',
        'icon': Icons.explore_outlined,
        'route': '/qibla',
        'color': AppColors.buttonCream,
      },
      {
        'title': 'المحفوظات',
        'icon': Icons.bookmark_outline,
        'route': '/bookmarks',
        'color': AppColors.buttonCream,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الخدمات السريعة',
            style: AppTextStyles.titleMedium,
          ),
          AppSpacing.verticalSm,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    onTap: () {
                      if (item['route'] == '/qibla' || item['route'] == '/bookmarks') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ميزة ${item['title']} قادمة قريباً إن شاء الله',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Amiri'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        context.push(item['route']);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'],
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          item['icon'] is String
                              ? Image.asset(
                                  item['icon'] as String,
                                  width: 40,
                                  height: 40,
                                )
                              : Icon(
                                  item['icon'] as IconData,
                                  size: 32,
                                  color: AppColors.primaryGreen,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
