import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';

/// Global mini player shown above the bottom nav bar while audio is active.
/// Reads playback state from [QuranAudioCubit] — never the audio service.
class QuranMiniPlayer extends StatelessWidget {
  const QuranMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranAudioCubit, QuranAudioState>(
      buildWhen: (previous, current) =>
          previous.isPlaying != current.isPlaying ||
          previous.activeAyah != current.activeAyah ||
          previous.surahNumber != current.surahNumber ||
          previous.surahName != current.surahName ||
          previous.versesCount != current.versesCount ||
          previous.isIdle != current.isIdle,
      builder: (context, state) {
        final cubit = context.read<QuranAudioCubit>();
        final surahNum = state.surahNumber ?? 1;
        final surahName = state.surahName ?? '';
        final versesCount = state.versesCount ?? 7;
        final ayahNum = state.activeAyah ?? 1;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: state.isIdle
              ? const SizedBox.shrink()
              : SafeArea(
                  top: false,
                  bottom: false,
                  child: Container(
            margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.cardDarkElevated,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.accentGold,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.push('/quran-listen', extra: {
                        'surahNumber': surahNum,
                        'surahName': surahName,
                        'versesCount': versesCount,
                        'initialAyah': ayahNum,
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تلاوة ${state.selectedReciter.name}',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: AppColors.accentGold,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${surahName.isNotEmpty ? 'سورة $surahName · ' : ''}آية ${QuranMetadata.toArabicDigits(ayahNum)} · اضغط لفتح المشغل',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: AppColors.textMuted,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    color: AppColors.sageGreen,
                    size: 32.r,
                  ),
                  onPressed: () {
                    if (state.isPlaying) {
                      cubit.pause();
                    } else {
                      cubit.resume();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 20.r,
                  ),
                  onPressed: () => cubit.stop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}
