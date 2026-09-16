import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';

class AudioPlayerControls extends StatelessWidget {
  final bool isDark;

  const AudioPlayerControls({
    super.key,
    required this.isDark,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Progress Slider
        StreamBuilder<Duration>(
          stream: context.read<QuranAudioCubit>().positionStream,
          builder: (context, posSnapshot) {
            final position = posSnapshot.data ?? Duration.zero;
            final duration =
                context.read<QuranAudioCubit>().duration ?? Duration.zero;
            final totalMs = duration.inMilliseconds;
            final currentMs = position.inMilliseconds;
            final progress =
                totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.accentGold,
                    inactiveTrackColor: isDark
                        ? AppColors.cardHighlight
                        : const Color(0xFFE5DEC9),
                    thumbColor: AppColors.accentGold,
                    trackHeight: 3.5.h,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 12.r),
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (val) {
                      if (totalMs > 0) {
                        final seekMs = (val * totalMs).toInt();
                        context
                            .read<QuranAudioCubit>()
                            .seek(Duration(milliseconds: seekMs));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalMs > 0 ? _formatDuration(position) : '--:--',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          color: isDark
                              ? AppColors.textDimmed
                              : AppColors.textDarkMuted,
                        ),
                      ),
                      Text(
                        totalMs > 0 ? _formatDuration(duration) : '--:--',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          color: isDark
                              ? AppColors.textDimmed
                              : AppColors.textDarkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 14.h),

        // 2. Playback Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Forward 10s Button
            GestureDetector(
              onTap: () => context.read<QuranAudioCubit>().seekForward10(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fast_forward_rounded,
                    color: isDark
                        ? AppColors.textMuted
                        : const Color(0xFF4A6B5D),
                    size: 24.r,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '١٠ ث',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.sp,
                      color: isDark
                          ? AppColors.textDimmed
                          : AppColors.textDarkMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 32.w),

            // Central Large Dark Green Play/Pause Button
            BlocBuilder<QuranAudioCubit, QuranAudioState>(
              buildWhen: (prev, curr) =>
                  prev.isPlaying != curr.isPlaying ||
                  prev.isBuffering != curr.isBuffering,
              builder: (context, audioState) {
                final isPlaying = audioState.isPlaying;
                final isBuffering = audioState.isBuffering;

                return GestureDetector(
                  onTap: () {
                    final cubit = context.read<QuranAudioCubit>();
                    if (isPlaying) {
                      cubit.pause();
                    } else {
                      cubit.resume();
                    }
                  },
                  child: Container(
                    width: 68.r,
                    height: 68.r,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.sageGreen
                          : const Color(0xFF1E4538),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.sageGreen
                                  : const Color(0xFF1E4538))
                              .withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: isBuffering
                        ? Center(
                            child: SizedBox(
                              width: 26.r,
                              height: 26.r,
                              child: CircularProgressIndicator(
                                color: isDark
                                    ? AppColors.bgDark
                                    : Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: isDark ? AppColors.bgDark : Colors.white,
                            size: 38.r,
                          ),
                  ),
                );
              },
            ),
            SizedBox(width: 32.w),

            // Rewind 10s Button
            GestureDetector(
              onTap: () => context.read<QuranAudioCubit>().seekBackward10(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fast_rewind_rounded,
                    color: isDark
                        ? AppColors.textMuted
                        : const Color(0xFF4A6B5D),
                    size: 24.r,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '١٠ ث',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.sp,
                      color: isDark
                          ? AppColors.textDimmed
                          : AppColors.textDarkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
