import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';

class CurrentReciterTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const CurrentReciterTile({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Bar with "تغيير القارئ" Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onTap,
              icon: Icon(
                Icons.swap_vert_rounded,
                size: 16.r,
                color: AppColors.accentGold,
              ),
              label: Text(
                'تغيير القارئ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'القارئ الصوتي',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textDarkPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.record_voice_over_rounded,
                  color: AppColors.accentGold,
                  size: 17.r,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Current Reciter Card (Tapping opens Modal Bottom Sheet)
        BlocBuilder<QuranAudioCubit, QuranAudioState>(
          buildWhen: (prev, curr) =>
              prev.selectedReciter != curr.selectedReciter,
          builder: (context, audioState) {
            final current = audioState.selectedReciter;

            return InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDarkElevated
                      : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.accentGold
                        .withValues(alpha: isDark ? 0.35 : 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Change Pill Button
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.iconBgCircleLight,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16.r, color: AppColors.accentGold),
                          SizedBox(width: 3.w),
                          Text(
                            'تبديل',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Reciter Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            current.displayName,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textDarkPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            current.subname,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 11.5.sp,
                              color: isDark
                                  ? AppColors.textDimmed
                                  : AppColors.textDarkMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Avatar
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF9E782F),
                                  AppColors.accentGold,
                                ]
                              : [
                                  const Color(0xFF1E4538),
                                  AppColors.primaryGreen,
                                ],
                        ),
                      ),
                      child: Icon(
                        Icons.record_voice_over_rounded,
                        size: 20.r,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
