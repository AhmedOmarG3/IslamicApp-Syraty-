import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_card.dart';

class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({super.key});

  static const String _verseText =
      'أَلا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ';
  static const String _surahRef = 'سورة الرعد — الآية ٢٨';

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.white,
      borderRadius: AppDimensions.radiusLg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      elevation: AppDimensions.elevationLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_quote, color: AppColors.primaryGreen, size: 22),
                  AppSpacing.horizontalSm,
                  Text(
                    'آية اليوم',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: AppColors.textSecondary),
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(text: '$_verseText\n[$_surahRef]'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم نسخ الآية بنجاح',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Amiri'),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          AppSpacing.verticalSm,
          Center(
            child: Text(
              '« $_verseText »',
              textAlign: TextAlign.center,
              style: AppTextStyles.ayahText.copyWith(
                fontSize: 22,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          AppSpacing.verticalSm,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _surahRef,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
