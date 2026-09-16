import 'package:equatable/equatable.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';

/// Discrete playback state exposed to the UI. High-frequency streams
/// (position ticks) are exposed separately via [QuranAudioCubit.positionStream]
/// so the UI can listen locally without rebuilding on every tick.
class QuranAudioState extends Equatable {
  final bool isPlaying;
  final bool isBuffering;
  final bool isPlaylistMode;

  /// Currently playing ayah number within the surah (1-based).
  final int? activeAyah;

  /// "surahNumber:ayahNumber" key used for per-ayah play indicators.
  final String? currentPlayingKey;

  final int? surahNumber;
  final String? surahName;
  final int? versesCount;
  final QuranReciter selectedReciter;

  const QuranAudioState({
    this.isPlaying = false,
    this.isBuffering = false,
    this.isPlaylistMode = false,
    this.activeAyah,
    this.currentPlayingKey,
    this.surahNumber,
    this.surahName,
    this.versesCount,
    required this.selectedReciter,
  });

  /// True when nothing has ever played (mini player hidden).
  bool get isIdle => !isPlaying && activeAyah == null;

  static const _sentinel = Object();

  QuranAudioState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    bool? isPlaylistMode,
    Object? activeAyah = _sentinel,
    Object? currentPlayingKey = _sentinel,
    Object? surahNumber = _sentinel,
    Object? surahName = _sentinel,
    Object? versesCount = _sentinel,
    QuranReciter? selectedReciter,
  }) {
    return QuranAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isPlaylistMode: isPlaylistMode ?? this.isPlaylistMode,
      activeAyah: activeAyah == _sentinel
          ? this.activeAyah
          : activeAyah as int?,
      currentPlayingKey: currentPlayingKey == _sentinel
          ? this.currentPlayingKey
          : currentPlayingKey as String?,
      surahNumber: surahNumber == _sentinel
          ? this.surahNumber
          : surahNumber as int?,
      surahName: surahName == _sentinel
          ? this.surahName
          : surahName as String?,
      versesCount: versesCount == _sentinel
          ? this.versesCount
          : versesCount as int?,
      selectedReciter: selectedReciter ?? this.selectedReciter,
    );
  }

  @override
  List<Object?> get props => [
        isPlaying,
        isBuffering,
        isPlaylistMode,
        activeAyah,
        currentPlayingKey,
        surahNumber,
        surahName,
        versesCount,
        selectedReciter,
      ];
}
