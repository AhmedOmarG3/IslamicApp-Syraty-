import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_card.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_state.dart';

class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoaded && state.lastReadSurahIndex != null) {
          final surah = state.surahs[state.lastReadSurahIndex!];
          final surahName = surah.getSurahName()[state.lastReadSurahIndex!];

          return AppCard(
            gradientColors: const [
              AppColors.primaryGreen,
              AppColors.secondaryGreen,
            ],
            borderRadius: AppDimensions.radiusLg,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            onTap: () {
              context.push('/surah-details', extra: {
                'surah': surah,
                'surahName': surahName,
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: AppColors.white, size: 20),
                        AppSpacing.horizontalSm,
                        Text(
                          'القراءة الأخيرة',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      'سورة $surahName',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonCream,
                        foregroundColor: AppColors.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        ),
                      ),
                      onPressed: () {
                        context.push('/surah-details', extra: {
                          'surah': surah,
                          'surahName': surahName,
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.primaryGreen),
                      label: Text(
                        'تابع القراءة',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  AppAssets.logoCrescent,
                  height: 110,
                ),
              ],
            ),
          );
        }

        return AppCard(
          backgroundColor: AppColors.primaryGreen,
          borderRadius: AppDimensions.radiusLg,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          onTap: () {
            context.push('/quran');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ابدأ قراءة القرآن الكريم',
                    style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'رحلة إيمانية مباركة في كتاب الله',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.white,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
