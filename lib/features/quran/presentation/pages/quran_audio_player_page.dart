import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/domain/services/quran_audio_service.dart';

class QuranAudioPlayerPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int versesCount;
  final int initialAyah;

  const QuranAudioPlayerPage({
    super.key,
    this.surahNumber = 1,
    this.surahName = 'الفاتحة',
    this.versesCount = 7,
    this.initialAyah = 1,
  });

  @override
  State<QuranAudioPlayerPage> createState() => _QuranAudioPlayerPageState();
}

class _QuranAudioPlayerPageState extends State<QuranAudioPlayerPage> {
  final QuranAudioService _audioService = QuranAudioService.instance;
  SurahModel? _surahData;
  bool _isLoadingSurah = true;
  late QuranReciter _selectedReciter;

  @override
  void initState() {
    super.initState();
    _selectedReciter = _audioService.selectedReciter;
    _loadSurahAndStartAudio();
  }

  Future<void> _loadSurahAndStartAudio() async {
    final surah = await LastReadService.loadSurah(widget.surahNumber);
    if (mounted) {
      setState(() {
        _surahData = surah;
        _isLoadingSurah = false;
      });

      // Start playing if not already playing this surah in playlist mode
      final isAlreadyPlayingThisSurahPlaylist =
          _audioService.currentSurahNumber == widget.surahNumber &&
          _audioService.isPlaylistMode &&
          _audioService.player.playing;

      if (!isAlreadyPlayingThisSurahPlaylist) {
        await _audioService.playSurah(
          surahNum: widget.surahNumber,
          versesCount: widget.versesCount,
          reciter: _selectedReciter,
          initialAyah: widget.initialAyah,
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getArabicAyahText(int? ayahNumber) {
    if (_surahData == null || _surahData!.verses.isEmpty) {
      return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    }
    final target = ayahNumber ?? widget.initialAyah;
    final index = target - 1;
    if (index >= 0 && index < _surahData!.verses.length) {
      return _surahData!.verses[index].text;
    }
    return _surahData!.verses[0].text;
  }

  void _onReciterChanged(QuranReciter reciter) {
    setState(() {
      _selectedReciter = reciter;
    });
    final currentAyah = _audioService.activeAyahNotifier.value ?? widget.initialAyah;
    _audioService.playSurah(
      surahNum: widget.surahNumber,
      versesCount: widget.versesCount,
      reciter: reciter,
      initialAyah: currentAyah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMakki = QuranMetadata.isMakki(widget.surahNumber);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'تلاوة سُورَةُ ${widget.surahName}',
      ),
      body: _isLoadingSurah
          ? const AudioPlayerSkeleton()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Column(
                children: [
                  // 1. Top Cover Card Matching Figma Screenshot 1
                  IslamicPatternCard(
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
                          widget.surahName,
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
                          '${isMakki ? 'مكية' : 'مدنية'} · ${QuranMetadata.toArabicDigits(widget.versesCount)} آية',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGoldLight,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // 2. Active Ayah Live Card (Clean Warm White Card in Light Mode)
                  ValueListenableBuilder<int?>(
                    valueListenable: _audioService.activeAyahNotifier,
                    builder: (context, activeAyah, _) {
                      final targetAyah = activeAyah ?? widget.initialAyah;
                      final verseText = _getArabicAyahText(targetAyah);

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
                  ),
                  SizedBox(height: 16.h),

                  // 3. Progress Slider Matching Figma (Warm Gold Thumb & Beige Track)
                  StreamBuilder<Duration>(
                    stream: _audioService.player.positionStream,
                    builder: (context, posSnapshot) {
                      final position = posSnapshot.data ?? Duration.zero;
                      final duration = _audioService.player.duration ?? Duration.zero;
                      final totalMs = duration.inMilliseconds;
                      final currentMs = position.inMilliseconds;
                      final progress = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

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
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                              overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (val) {
                                if (totalMs > 0) {
                                  final seekMs = (val * totalMs).toInt();
                                  _audioService.player.seek(Duration(milliseconds: seekMs));
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
                                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                                  ),
                                ),
                                Text(
                                  totalMs > 0 ? _formatDuration(duration) : '--:--',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11.sp,
                                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
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

                  // 4. Playback Controls Row Matching Screenshot 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Forward 10s Button
                      GestureDetector(
                        onTap: () => _audioService.seekForward10(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fast_forward_rounded,
                              color: isDark ? AppColors.textMuted : const Color(0xFF4A6B5D),
                              size: 24.r,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '١٠ ث',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10.sp,
                                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 32.w),

                      // Central Large Dark Green Play/Pause Button
                      StreamBuilder<PlayerState>(
                        stream: _audioService.player.playerStateStream,
                        builder: (context, snapshot) {
                          final state = snapshot.data;
                          final isPlaying = state?.playing ?? false;
                          final isBuffering = state?.processingState == ProcessingState.buffering ||
                              state?.processingState == ProcessingState.loading;

                          return GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                _audioService.pause();
                              } else {
                                _audioService.resume();
                              }
                            },
                            child: Container(
                              width: 68.r,
                              height: 68.r,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.sageGreen : const Color(0xFF1E4538),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
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
                                          color: isDark ? AppColors.bgDark : Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                        onTap: () => _audioService.seekBackward10(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fast_rewind_rounded,
                              color: isDark ? AppColors.textMuted : const Color(0xFF4A6B5D),
                              size: 24.r,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '١٠ ث',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10.sp,
                                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  // 5. Reciter Selection Section Matching Screenshot 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'اختر القارئ',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.accentGold,
                        size: 16.r,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Reciter Horizontal Pills (Selected: Deep emerald with white text, Unselected: Warm white card)
                  SizedBox(
                    height: 48.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // RTL order
                      itemCount: QuranAudioService.availableReciters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        final reciter = QuranAudioService.availableReciters[index];
                        final isSelected = reciter.id == _selectedReciter.id;

                        return GestureDetector(
                          onTap: () => _onReciterChanged(reciter),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                                  : (isDark ? AppColors.cardDarkElevated : AppColors.cardLight),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                                    : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                                width: 1.2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              reciter.name,
                              style: AppTextStyles.caption.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }
}
