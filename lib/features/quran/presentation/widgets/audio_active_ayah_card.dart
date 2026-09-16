import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';

class AudioActiveAyahCard extends StatelessWidget {
  final int initialAyah;
  final String Function(int? ayahNumber) getAyahText;
  final bool isDark;

  const AudioActiveAyahCard({
    super.key,
    required this.initialAyah,
    required this.getAyahText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranAudioCubit, QuranAudioState>(
      buildWhen: (prev, curr) => prev.activeAyah != curr.activeAyah,
      builder: (context, audioState) {
        final targetAyah = audioState.activeAyah ?? initialAyah;
        final verseText = getAyahText(targetAyah);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : AppColors.accentGold.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'الآية رقم ${QuranMetadata.toArabicDigits(targetAyah)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGold,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                verseText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
