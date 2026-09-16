import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class AudioSurahCoverCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int versesCount;

  const AudioSurahCoverCard({
    super.key,
    required this.surahName,
    required this.surahNumber,
    required this.versesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isMakki = QuranMetadata.isMakki(surahNumber);

    return IslamicPatternCard(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      borderRadius: BorderRadius.circular(26.r),
      cellSize: 50.0,
      gradientColors: const [
        Color(0xFF1E483A),
        Color(0xFF17382D),
        Color(0xFF122C23),
      ],
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF122C23).withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 32.r,
            color: AppColors.accentGold,
          ),
          SizedBox(height: 12.h),
          Text(
            surahName,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 34.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          // Golden small divider line
          Container(
            width: 44.w,
            height: 1.5,
            color: AppColors.accentGold.withValues(alpha: 0.6),
          ),
          SizedBox(height: 10.h),
          Text(
            '${isMakki ? 'مكية' : 'مدنية'} · ${QuranMetadata.toArabicDigits(versesCount)} آية',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentGoldLight,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
