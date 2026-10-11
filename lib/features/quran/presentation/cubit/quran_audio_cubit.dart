import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_state.dart';

export 'package:siraty/features/quran/presentation/cubit/quran_audio_state.dart';

/// Presentation-layer controller for Quran audio playback.
///
/// Wraps [QuranAudioService] (registered in getIt) so widgets never touch
/// the service, its ValueNotifiers, or the raw [AudioPlayer] directly.
/// Provided as an app-wide singleton in `SiratyApp` because playback must
/// survive navigation (mini player + full player page).
class QuranAudioCubit extends Cubit<QuranAudioState> {
  final QuranAudioService _service;

  StreamSubscription? _playerStateSub;

  QuranAudioCubit({required QuranAudioService service})
      : _service = service,
        super(
          QuranAudioState(selectedReciter: service.selectedReciter),
        ) {
    _service.isPlayingNotifier.addListener(_onIsPlaying);
    _service.activeAyahNotifier.addListener(_onActiveAyah);
    _service.currentPlayingKey.addListener(_onPlayingKey);
    _playerStateSub = _service.player.playerStateStream.listen((playerState) {
      emit(
        state.copyWith(
          isBuffering:
              playerState.processingState == ProcessingState.buffering ||
                  playerState.processingState == ProcessingState.loading,
        ),
      );
    });
  }

  // ---------------------------------------------------------------------
  // Read-only pass-throughs (high-frequency / static data)
  // ---------------------------------------------------------------------

  static List<QuranReciter> get availableReciters =>
      QuranAudioService.availableReciters;

  /// Position ticks for the progress slider. Kept as a stream (not state)
  /// so the whole subtree doesn't rebuild ~5x per second.
  Stream<Duration> get positionStream => _service.player.positionStream;

  /// Duration of the active track, or null while it loads.
  Duration? get duration => _service.duration;

  // ---------------------------------------------------------------------
  // Listener bridges from the service's ValueNotifiers
  // ---------------------------------------------------------------------

  void _onIsPlaying() {
    emit(state.copyWith(isPlaying: _service.isPlayingNotifier.value));
  }

  void _onActiveAyah() {
    emit(state.copyWith(activeAyah: _service.activeAyahNotifier.value));
  }

  void _onPlayingKey() {
    emit(
      state.copyWith(currentPlayingKey: _service.currentPlayingKey.value),
    );
  }

  // ---------------------------------------------------------------------
  // Playback commands
  // ---------------------------------------------------------------------

  Future<void> playSurah({
    required int surahNum,
    required int versesCount,
    String? surahName,
    QuranReciter? reciter,
    int initialAyah = 1,
  }) async {
    emit(
      state.copyWith(
        isPlaylistMode: true,
        surahNumber: surahNum,
        surahName: surahName ?? state.surahName,
        versesCount: versesCount,
        selectedReciter: reciter ?? state.selectedReciter,
        activeAyah: initialAyah,
      ),
    );
    await _service.playSurah(
      surahNum: surahNum,
      versesCount: versesCount,
      surahName: surahName,
      reciter: reciter,
      initialAyah: initialAyah,
    );
  }

  Future<void> playAyah({
    required int surahNum,
    required int ayahNum,
    String? surahName,
    int? versesCount,
    QuranReciter? reciter,
  }) async {
    emit(
      state.copyWith(
        isPlaylistMode: false,
        surahNumber: surahNum,
        surahName: surahName ?? state.surahName,
        versesCount: versesCount ?? state.versesCount,
        selectedReciter: reciter ?? state.selectedReciter,
        activeAyah: ayahNum,
      ),
    );
    await _service.playAyah(
      surahNum: surahNum,
      ayahNum: ayahNum,
      surahName: surahName,
      versesCount: versesCount,
      reciter: reciter,
    );
  }

  Future<void> pause() => _service.pause();

  Future<void> resume() async {
    if (_service.player.audioSource == null &&
        state.surahNumber != null &&
        state.versesCount != null) {
      await playSurah(
        surahNum: state.surahNumber!,
        versesCount: state.versesCount!,
        surahName: state.surahName,
        reciter: state.selectedReciter,
        initialAyah: state.activeAyah ?? 1,
      );
      return;
    }
    await _service.resume();
  }

  Future<void> stop() async {
    await _service.stop();
    emit(
      state.copyWith(
        isPlaying: false,
        isBuffering: false,
        isPlaylistMode: false,
        activeAyah: null,
        currentPlayingKey: null,
        surahNumber: null,
        surahName: null,
        versesCount: null,
      ),
    );
  }

  void setReciter(QuranReciter reciter) {
    _service.setReciter(reciter);
    emit(state.copyWith(selectedReciter: reciter));
  }

  Future<void> seek(Duration position) => _service.seek(position);

  Future<void> seekForward10() => _service.seekForward10();

  Future<void> seekBackward10() => _service.seekBackward10();

  Future<void> nextAyah() => _service.nextAyah();

  Future<void> previousAyah() => _service.previousAyah();

  @override
  Future<void> close() {
    _service.isPlayingNotifier.removeListener(_onIsPlaying);
    _service.activeAyahNotifier.removeListener(_onActiveAyah);
    _service.currentPlayingKey.removeListener(_onPlayingKey);
    _playerStateSub?.cancel();
    return super.close();
  }
}
