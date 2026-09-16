import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class QuranReciter {
  final String id;
  final String name;
  final String subname;

  const QuranReciter({
    required this.id,
    required this.name,
    required this.subname,
  });

  /// Clear display name distinguishing recitation types (e.g. Murattal vs Mujawwad)
  String get displayName {
    if (id.contains('Mujawwad') || subname.contains('المجود')) {
      return '$name (مجود)';
    } else if (id.contains('Murattal') || subname.contains('المرتل')) {
      if (name.contains('عبد الباسط') || name.contains('المنشاوي')) {
        return '$name (مرتل)';
      }
    }
    return name;
  }
}

/// Plugin-bound audio playback infrastructure (just_audio).
/// Lives in the data layer; presentation consumes it through
/// [QuranAudioCubit] and getIt — never directly.
class QuranAudioService {
  QuranAudioService();

  late final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _playerStateSubscription;

  bool _isPlaylistMode = false;
  bool get isPlaylistMode => _isPlaylistMode;

  static const List<QuranReciter> availableReciters = [
    QuranReciter(
      id: 'Alafasy_128kbps',
      name: 'مشاري راشد العفاسي',
      subname: 'تلاوة حفص عن عاصم',
    ),
    QuranReciter(
      id: 'Minshawy_Murattal_128kbps',
      name: 'محمد صديق المنشاوي',
      subname: 'المصحف المرتل',
    ),
    QuranReciter(
      id: 'Minshawy_Mujawwad_192kbps',
      name: 'محمد صديق المنشاوي',
      subname: 'المصحف المجود',
    ),
    QuranReciter(
      id: 'Abdul_Basit_Murattal_192kbps',
      name: 'عبد الباسط عبد الصمد',
      subname: 'المصحف المرتل',
    ),
    QuranReciter(
      id: 'Abdul_Basit_Mujawwad_128kbps',
      name: 'عبد الباسط عبد الصمد',
      subname: 'المصحف المجود',
    ),
    QuranReciter(
      id: 'Husary_128kbps',
      name: 'محمود خليل الحصري',
      subname: 'المصحف المرتل',
    ),
    QuranReciter(
      id: 'Abdurrahmaan_As-Sudais_192kbps',
      name: 'عبد الرحمن السديس',
      subname: 'إمام المسجد الحرام',
    ),
    QuranReciter(
      id: 'Saood_ash-Shuraym_128kbps',
      name: 'سعود الشريم',
      subname: 'إمام المسجد الحرام السابق',
    ),
    QuranReciter(
      id: 'MaherAlMuaiqly128kbps',
      name: 'ماهر المعيقلي',
      subname: 'إمام المسجد الحرام',
    ),
    QuranReciter(
      id: 'Yasser_Ad-Dussary_128kbps',
      name: 'ياسر الدوسري',
      subname: 'إمام المسجد الحرام',
    ),
    QuranReciter(
      id: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
      name: 'أحمد بن علي العجمي',
      subname: 'تلاوة حفص عن عاصم',
    ),
    QuranReciter(
      id: 'Ghamadi_40kbps',
      name: 'سعد الغامدي',
      subname: 'تلاوة خاشعة',
    ),
    QuranReciter(
      id: 'Fares_Abbad_64kbps',
      name: 'فارس عباد',
      subname: 'تلاوة يمنية خاشعة',
    ),
    QuranReciter(
      id: 'Abu_Bakr_Ash-Shaatree_128kbps',
      name: 'أبو بكر الشاطري',
      subname: 'تلاوة حجازية هادئة',
    ),
    QuranReciter(
      id: 'Ali_Jaber_64kbps',
      name: 'علي جابر',
      subname: 'إمام المسجد الحرام الأسبق',
    ),
    QuranReciter(
      id: 'Hani_Rifai_192kbps',
      name: 'هاني الرفاعي',
      subname: 'تلاوة مؤثرة خاشعة',
    ),
    QuranReciter(
      id: 'Abdullaah_3awwaad_Al-Juhaynee_128kbps',
      name: 'عبد الله عواد الجهني',
      subname: 'إمام المسجد الحرام',
    ),
    QuranReciter(
      id: 'Nasser_Alqatami_128kbps',
      name: 'ناصر القطامي',
      subname: 'تلاوة نجدية محبوبة',
    ),
    QuranReciter(
      id: 'Muhammad_Ayyoub_128kbps',
      name: 'محمد أيوب',
      subname: 'إمام المسجد النبوي الأسبق',
    ),
    QuranReciter(
      id: 'Mohammad_al_Tablaway_128kbps',
      name: 'محمد محمود الطبلاوي',
      subname: 'المصحف المرتل',
    ),
    QuranReciter(
      id: 'Ahmed_Neana_128kbps',
      name: 'أحمد نعينع',
      subname: 'المصحف المرتل',
    ),
    QuranReciter(
      id: 'Ayman_Sowaid_64kbps',
      name: 'أيمن رشدي سويد',
      subname: 'المصحف المعلم المتقن',
    ),
  ];

  QuranReciter _selectedReciter = availableReciters[0];
  QuranReciter get selectedReciter => _selectedReciter;

  int? currentSurahNumber;
  String? currentSurahName;
  int? currentVersesCount;
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> currentPlayingKey = ValueNotifier<String?>(null);
  final ValueNotifier<int?> activeAyahNotifier = ValueNotifier<int?>(null);

  void setReciter(QuranReciter reciter) {
    _selectedReciter = reciter;
  }

  /// Construct EveryAyah URL for a specific verse
  static String getVerseAudioUrl(int surahNum, int ayahNum, String reciterId) {
    final sStr = surahNum.toString().padLeft(3, '0');
    final aStr = ayahNum.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$reciterId/$sStr$aStr.mp3';
  }

  /// Play a full surah as a gapless playlist of verses
  Future<void> playSurah({
    required int surahNum,
    required int versesCount,
    String? surahName,
    QuranReciter? reciter,
    int initialAyah = 1,
  }) async {
    final rec = reciter ?? _selectedReciter;
    if (versesCount <= 0) {
      debugPrint('Cannot play surah $surahNum: no verses available');
      return;
    }
    _selectedReciter = rec;
    currentSurahNumber = surahNum;
    if (surahName != null) currentSurahName = surahName;
    currentVersesCount = versesCount;
    _isPlaylistMode = true;

    // Cancel old stream listeners so they don't leak or overwrite
    await _currentIndexSubscription?.cancel();
    _currentIndexSubscription = null;
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;

    final targetIndex = (initialAyah - 1).clamp(0, versesCount - 1);
    activeAyahNotifier.value = targetIndex + 1;
    currentPlayingKey.value = '$surahNum:${targetIndex + 1}';

    final sources = List<AudioSource>.generate(versesCount, (index) {
      final ayahNum = index + 1;
      final url = getVerseAudioUrl(surahNum, ayahNum, rec.id);
      return AudioSource.uri(Uri.parse(url), tag: ayahNum);
    });

    try {
      isPlayingNotifier.value = true;
      await _player.stop();
      await _player.setAudioSources(
        sources,
        initialIndex: targetIndex,
        initialPosition: Duration.zero,
      );
      _player.play();

      _currentIndexSubscription = _player.currentIndexStream.listen((index) {
        if (_isPlaylistMode && index != null && index < versesCount) {
          activeAyahNotifier.value = index + 1;
          currentPlayingKey.value = '$surahNum:${index + 1}';
        }
      });

      _playerStateSubscription = _player.playerStateStream.listen((state) {
        isPlayingNotifier.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          isPlayingNotifier.value = false;
          currentPlayingKey.value = null;
        }
      });
    } catch (e) {
      isPlayingNotifier.value = false;
      currentPlayingKey.value = null;
      debugPrint('Error playing surah audio: $e');
    }
  }

  /// Play a single verse directly
  Future<void> playAyah({
    required int surahNum,
    required int ayahNum,
    String? surahName,
    int? versesCount,
    QuranReciter? reciter,
  }) async {
    final rec = reciter ?? _selectedReciter;
    _selectedReciter = rec;
    currentSurahNumber = surahNum;
    if (surahName != null) currentSurahName = surahName;
    if (versesCount != null) currentVersesCount = versesCount;
    _isPlaylistMode = false;

    // Cancel previous listeners to prevent old playlist listeners from resetting to index 0 (Ayah 1)
    await _currentIndexSubscription?.cancel();
    _currentIndexSubscription = null;
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;

    activeAyahNotifier.value = ayahNum;
    final url = getVerseAudioUrl(surahNum, ayahNum, rec.id);
    final key = '$surahNum:$ayahNum';

    try {
      currentPlayingKey.value = key;
      isPlayingNotifier.value = true;
      await _player.stop();
      await _player.setUrl(url);
      _player.play();

      _playerStateSubscription = _player.playerStateStream.listen((state) {
        isPlayingNotifier.value = state.playing;
        if (state.processingState == ProcessingState.completed) {
          currentPlayingKey.value = null;
          isPlayingNotifier.value = false;
          // Retain activeAyahNotifier so UI preserves the active Ayah display
        }
      });
    } catch (e) {
      isPlayingNotifier.value = false;
      currentPlayingKey.value = null;
      debugPrint('Error playing verse audio: $e');
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _currentIndexSubscription?.cancel();
    _currentIndexSubscription = null;
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _player.stop();
    isPlayingNotifier.value = false;
    currentPlayingKey.value = null;
    activeAyahNotifier.value = null;
    currentSurahNumber = null;
    currentSurahName = null;
    currentVersesCount = null;
    _isPlaylistMode = false;
  }

  /// Pause current playback
  Future<void> pause() async {
    await _player.pause();
    isPlayingNotifier.value = false;
  }

  /// Resume playback
  Future<void> resume() async {
    // After natural completion, play() would set playing=true while the
    // position sits at the end — restart from the beginning instead.
    if (_player.processingState == ProcessingState.completed) {
      if (_isPlaylistMode) {
        await _player.seek(Duration.zero, index: 0);
      } else {
        await _player.seek(Duration.zero);
      }
    }
    _player.play();
    isPlayingNotifier.value = true;
  }

  /// Seek forward 10 seconds
  Future<void> seekForward10() async {
    final current = _player.position;
    final target = current + const Duration(seconds: 10);
    await _player.seek(target);
  }

  /// Seek backward 10 seconds
  Future<void> seekBackward10() async {
    final current = _player.position;
    final target = current - const Duration(seconds: 10);
    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  /// Next Ayah in playlist
  Future<void> nextAyah() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  /// Previous Ayah in playlist
  Future<void> previousAyah() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  /// Current playback position of the active track
  Duration get position => _player.position;

  /// Total duration of the active track (null while loading)
  Duration? get duration => _player.duration;

  /// Seek to an absolute position within the active track
  Future<void> seek(Duration position) => _player.seek(position);

  /// Release the underlying platform player.
  /// Called when playback is fully abandoned (app teardown).
  Future<void> dispose() async {
    await _currentIndexSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _player.dispose();
  }
}
