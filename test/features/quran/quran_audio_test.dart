import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_state.dart';

void main() {
  group('QuranAudioState Tests', () {
    const defaultReciter = QuranReciter(
      id: 'Alafasy_128kbps',
      name: 'مشاري راشد العفاسي',
      subname: 'تلاوة حفص عن عاصم',
    );

    test('Initial state is idle', () {
      const state = QuranAudioState(selectedReciter: defaultReciter);
      expect(state.isPlaying, false);
      expect(state.activeAyah, isNull);
      expect(state.isIdle, true);
    });

    test('Playing state is not idle', () {
      final state = const QuranAudioState(selectedReciter: defaultReciter)
          .copyWith(
            isPlaying: true,
            activeAyah: 1,
            surahNumber: 2,
            surahName: 'البقرة',
          );
      expect(state.isPlaying, true);
      expect(state.activeAyah, 1);
      expect(state.isIdle, false);
    });

    test('copyWith properly clears nullable fields when passed null (Stop scenario)', () {
      final activeState = const QuranAudioState(selectedReciter: defaultReciter)
          .copyWith(
            isPlaying: true,
            activeAyah: 15,
            surahNumber: 2,
            surahName: 'البقرة',
            versesCount: 286,
            currentPlayingKey: '2:15',
          );

      expect(activeState.activeAyah, 15);
      expect(activeState.isIdle, false);

      // Simulate cubit.stop()
      final stoppedState = activeState.copyWith(
        isPlaying: false,
        isBuffering: false,
        isPlaylistMode: false,
        activeAyah: null,
        currentPlayingKey: null,
        surahNumber: null,
        surahName: null,
        versesCount: null,
      );

      expect(stoppedState.isPlaying, false);
      expect(stoppedState.activeAyah, isNull,
          reason: 'activeAyah must be cleared to null on stop');
      expect(stoppedState.surahNumber, isNull);
      expect(stoppedState.surahName, isNull);
      expect(stoppedState.versesCount, isNull);
      expect(stoppedState.currentPlayingKey, isNull);
      expect(stoppedState.isIdle, true,
          reason: 'State must be idle so mini player disappears');
    });

    test('copyWith preserves values when fields are not passed', () {
      final state = const QuranAudioState(selectedReciter: defaultReciter)
          .copyWith(
            activeAyah: 5,
            surahNumber: 1,
            surahName: 'الفاتحة',
          );

      final updatedState = state.copyWith(isPlaying: true);

      expect(updatedState.activeAyah, 5);
      expect(updatedState.surahNumber, 1);
      expect(updatedState.surahName, 'الفاتحة');
      expect(updatedState.isPlaying, true);
    });
  });
}
