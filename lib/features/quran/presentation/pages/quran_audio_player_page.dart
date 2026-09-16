import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/features/quran/data/models/surah_model.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';
import 'package:siraty/features/quran/domain/services/last_read_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';
import '../widgets/audio_active_ayah_card.dart';
import '../widgets/audio_player_controls.dart';
import '../widgets/audio_surah_cover_card.dart';
import '../widgets/current_reciter_tile.dart';
import '../widgets/reciter_selection_sheet.dart';

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
  SurahModel? _surahData;
  bool _isLoadingSurah = true;

  @override
  void initState() {
    super.initState();
    _loadSurahAndStartAudio();
  }

  Future<void> _loadSurahAndStartAudio() async {
    final surah = await LastReadService.loadSurah(widget.surahNumber);
    if (mounted) {
      setState(() {
        _surahData = surah;
        _isLoadingSurah = false;
      });

      final cubit = context.read<QuranAudioCubit>();

      // Start playing if not already playing this surah in playlist mode at the requested ayah
      final isAlreadyPlayingThisSurahAyah =
          cubit.state.surahNumber == widget.surahNumber &&
              cubit.state.isPlaylistMode &&
              cubit.state.isPlaying &&
              cubit.state.activeAyah == widget.initialAyah;

      if (!isAlreadyPlayingThisSurahAyah) {
        await cubit.playSurah(
          surahNum: widget.surahNumber,
          versesCount: widget.versesCount,
          surahName: widget.surahName,
          initialAyah: widget.initialAyah,
        );
      }
    }
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
    final cubit = context.read<QuranAudioCubit>();
    final currentAyah = cubit.state.activeAyah ?? widget.initialAyah;
    cubit.playSurah(
      surahNum: widget.surahNumber,
      versesCount: widget.versesCount,
      surahName: widget.surahName,
      reciter: reciter,
      initialAyah: currentAyah,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  // 1. Top Cover Card
                  AudioSurahCoverCard(
                    surahName: widget.surahName,
                    surahNumber: widget.surahNumber,
                    versesCount: widget.versesCount,
                  ),
                  SizedBox(height: 18.h),

                  // 2. Active Ayah Live Card
                  AudioActiveAyahCard(
                    initialAyah: widget.initialAyah,
                    getAyahText: _getArabicAyahText,
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.h),

                  // 3 & 4. Progress Slider & Playback Controls
                  AudioPlayerControls(isDark: isDark),
                  SizedBox(height: 28.h),

                  // 5. Current Reciter Tile (Tap opens modal sheet)
                  CurrentReciterTile(
                    isDark: isDark,
                    onTap: () => ReciterSelectionSheet.show(
                      context,
                      isDark: isDark,
                      onReciterSelected: _onReciterChanged,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }
}
