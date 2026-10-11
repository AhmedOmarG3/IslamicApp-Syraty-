import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';

/// Detailed metadata of a locally downloaded surah.
class DownloadedSurahDetail {
  final String reciterId;
  final String reciterName;
  final int surahNumber;
  final String surahName;
  final int totalAyahs;
  final int downloadedAyahsCount;
  final List<int> downloadedAyahs;
  final int sizeBytes;

  const DownloadedSurahDetail({
    required this.reciterId,
    required this.reciterName,
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
    required this.downloadedAyahsCount,
    required this.downloadedAyahs,
    required this.sizeBytes,
  });

  bool get isFullyDownloaded => downloadedAyahsCount >= totalAyahs;
  String get formattedSize => QuranDownloadService.formatBytes(sizeBytes);

  /// Friendly summary of ayahs range e.g. "كاملة (١١٠ آية)" or "٢٠ من أصل ١١٠ آية"
  String get ayahsDescription {
    if (isFullyDownloaded) {
      return 'كاملة ($totalAyahs آية)';
    }
    if (downloadedAyahs.isEmpty) return '٠ آية';
    if (downloadedAyahs.length == 1) {
      return 'آية رقم ${downloadedAyahs.first}';
    }
    return '$downloadedAyahsCount من $totalAyahs آية (${downloadedAyahs.first} - ${downloadedAyahs.last})';
  }
}

/// Progress information for a surah download job.
class SurahDownloadProgress {
  final String reciterId;
  final int surahNumber;
  final int totalAyahs;
  final int completedAyahs;
  final bool isDownloading;
  final bool isFailed;
  final String? errorMessage;

  const SurahDownloadProgress({
    required this.reciterId,
    required this.surahNumber,
    required this.totalAyahs,
    required this.completedAyahs,
    this.isDownloading = false,
    this.isFailed = false,
    this.errorMessage,
  });

  double get progressFraction =>
      totalAyahs == 0 ? 0.0 : (completedAyahs / totalAyahs).clamp(0.0, 1.0);

  int get progressPercent => (progressFraction * 100).round();

  bool get isFullyDownloaded =>
      totalAyahs > 0 && completedAyahs >= totalAyahs;

  SurahDownloadProgress copyWith({
    String? reciterId,
    int? surahNumber,
    int? totalAyahs,
    int? completedAyahs,
    bool? isDownloading,
    bool? isFailed,
    String? errorMessage,
  }) {
    return SurahDownloadProgress(
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      completedAyahs: completedAyahs ?? this.completedAyahs,
      isDownloading: isDownloading ?? this.isDownloading,
      isFailed: isFailed ?? this.isFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Service responsible for managing offline Quran audio files on local disk.
/// Maintains an in-memory O(1) index so checks take 0ms and never block the UI.
class QuranDownloadService {
  final Dio _dio;

  QuranDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  String? _baseStoragePath;

  /// Fast in-memory index: key is '$reciterId:$surahNum', value is Set of downloaded ayah numbers.
  final Map<String, Set<int>> _downloadIndex = {};

  /// Active cancel tokens per '$reciterId:$surahNum'
  final Map<String, CancelToken> _activeCancelTokens = {};

  /// Notifier for index updates so listeners/cubits can react immediately.
  final ValueNotifier<int> indexRevisionNotifier = ValueNotifier<int>(0);

  static String _key(String reciterId, int surahNum) => '$reciterId:$surahNum';

  /// Initializes the local storage directory and populates the in-memory index.
  /// Also sweeps any leftover `.tmp` files from unexpected kills.
  Future<void> init() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      _baseStoragePath = '${docDir.path}/quran_audio';
      final baseDir = Directory(_baseStoragePath!);
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
        return;
      }

      await _rebuildIndexFromDisk(baseDir);
    } catch (e) {
      debugPrint('Error initializing QuranDownloadService: $e');
    }
  }

  Future<void> _rebuildIndexFromDisk(Directory baseDir) async {
    _downloadIndex.clear();
    final reciterEntities = await baseDir.list().toList();

    for (final reciterEntity in reciterEntities) {
      if (reciterEntity is Directory) {
        final reciterId = reciterEntity.uri.pathSegments
            .where((s) => s.isNotEmpty)
            .last;

        final surahEntities = await reciterEntity.list().toList();
        for (final surahEntity in surahEntities) {
          if (surahEntity is Directory) {
            final surahSegment = surahEntity.uri.pathSegments
                .where((s) => s.isNotEmpty)
                .last;
            final surahNum = int.tryParse(surahSegment);
            if (surahNum == null) continue;

            final fileEntities = await surahEntity.list().toList();
            final key = _key(reciterId, surahNum);
            final ayahSet = <int>{};

            for (final fileEntity in fileEntities) {
              if (fileEntity is File) {
                final name = fileEntity.uri.pathSegments.last;
                // Delete orphan temporary files from aborted downloads
                if (name.endsWith('.tmp')) {
                  try {
                    await fileEntity.delete();
                  } catch (_) {}
                  continue;
                }

                if (name.endsWith('.mp3')) {
                  // e.g. "002001.mp3" -> substring(3, 6) = "001" -> ayah 1
                  final baseName = name.replaceAll('.mp3', '');
                  if (baseName.length >= 6) {
                    final ayahStr = baseName.substring(3);
                    final ayahNum = int.tryParse(ayahStr);
                    if (ayahNum != null) {
                      ayahSet.add(ayahNum);
                    }
                  }
                }
              }
            }

            if (ayahSet.isNotEmpty) {
              _downloadIndex[key] = ayahSet;
            }
          }
        }
      }
    }
    indexRevisionNotifier.value++;
  }

  // ---------------------------------------------------------------------------
  // Synchronous, Zero-Delay In-Memory Checks
  // ---------------------------------------------------------------------------

  /// Checks if a specific ayah is already downloaded locally (O(1) in memory).
  bool isAyahDownloaded(String reciterId, int surahNum, int ayahNum) {
    final key = _key(reciterId, surahNum);
    return _downloadIndex[key]?.contains(ayahNum) ?? false;
  }

  /// Checks if a surah is fully downloaded locally (O(1) in memory).
  bool isSurahFullyDownloaded(
    String reciterId,
    int surahNum,
    int totalAyahs,
  ) {
    if (totalAyahs <= 0) return false;
    final key = _key(reciterId, surahNum);
    final count = _downloadIndex[key]?.length ?? 0;
    return count >= totalAyahs;
  }

  /// Returns the number of downloaded ayahs for a given surah.
  int getDownloadedAyahsCount(String reciterId, int surahNum) {
    final key = _key(reciterId, surahNum);
    return _downloadIndex[key]?.length ?? 0;
  }

  /// Returns the local absolute file path for an ayah if it is downloaded, or null.
  String? getLocalAyahFilePath(String reciterId, int surahNum, int ayahNum) {
    if (!isAyahDownloaded(reciterId, surahNum, ayahNum)) return null;
    return _getAyahFilePath(reciterId, surahNum, ayahNum);
  }

  String _getSurahDirPath(String reciterId, int surahNum) {
    final sStr = surahNum.toString().padLeft(3, '0');
    return '$_baseStoragePath/$reciterId/$sStr';
  }

  String _getAyahFilePath(String reciterId, int surahNum, int ayahNum) {
    final sStr = surahNum.toString().padLeft(3, '0');
    final aStr = ayahNum.toString().padLeft(3, '0');
    return '${_getSurahDirPath(reciterId, surahNum)}/$sStr$aStr.mp3';
  }

  // ---------------------------------------------------------------------------
  // Download Operations (Atomic .tmp -> .mp3 with Concurrency Queue)
  // ---------------------------------------------------------------------------

  /// Downloads a single ayah. Atomic and safe from corruption.
  Future<bool> downloadSingleAyah({
    required String reciterId,
    required int surahNum,
    required int ayahNum,
    CancelToken? cancelToken,
  }) async {
    if (_baseStoragePath == null) await init();

    if (isAyahDownloaded(reciterId, surahNum, ayahNum)) {
      return true; // Already downloaded
    }

    final dirPath = _getSurahDirPath(reciterId, surahNum);
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final targetPath = _getAyahFilePath(reciterId, surahNum, ayahNum);
    final tmpPath = '$targetPath.tmp';
    final url = QuranAudioService.getVerseAudioUrl(surahNum, ayahNum, reciterId);

    try {
      final response = await _dio.download(
        url,
        tmpPath,
        cancelToken: cancelToken,
        deleteOnError: true,
      );

      if (response.statusCode == 200 || response.statusCode == 206) {
        final tmpFile = File(tmpPath);
        if (await tmpFile.exists()) {
          final length = await tmpFile.length();
          if (length > 1000) {
            // Rename atomically to final .mp3
            await tmpFile.rename(targetPath);
            // Update in-memory index
            final key = _key(reciterId, surahNum);
            _downloadIndex.putIfAbsent(key, () => <int>{}).add(ayahNum);
            indexRevisionNotifier.value++;
            return true;
          } else {
            await tmpFile.delete();
          }
        }
      }
    } catch (e) {
      final tmpFile = File(tmpPath);
      if (await tmpFile.exists()) {
        try {
          await tmpFile.delete();
        } catch (_) {}
      }
      if (e is DioException && CancelToken.isCancel(e)) {
        rethrow;
      }
      debugPrint('Error downloading ayah $surahNum:$ayahNum: $e');
    }
    return false;
  }

  /// Downloads all ayahs for a surah using a controlled concurrent queue (default 3 concurrent).
  /// Skips already downloaded ayahs automatically (Smart Resume).
  /// Calls [onProgress] on each finished ayah.
  Future<void> downloadSurah({
    required String reciterId,
    required int surahNum,
    required int totalAyahs,
    void Function(int completed, int total)? onProgress,
    int concurrency = 3,
  }) async {
    if (_baseStoragePath == null) await init();

    final key = _key(reciterId, surahNum);
    // Cancel any existing job for this surah first
    cancelSurahDownload(reciterId, surahNum);

    final cancelToken = CancelToken();
    _activeCancelTokens[key] = cancelToken;

    try {
      final neededAyahs = <int>[];
      for (int i = 1; i <= totalAyahs; i++) {
        if (!isAyahDownloaded(reciterId, surahNum, i)) {
          neededAyahs.add(i);
        }
      }

      var completedCount = totalAyahs - neededAyahs.length;
      onProgress?.call(completedCount, totalAyahs);

      if (neededAyahs.isEmpty) {
        return;
      }

      // Process with concurrency pool
      int nextIndex = 0;
      final activeFutures = <Future<void>>{};

      while (nextIndex < neededAyahs.length || activeFutures.isNotEmpty) {
        if (cancelToken.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.cancel,
          );
        }

        while (activeFutures.length < concurrency && nextIndex < neededAyahs.length) {
          final ayahNum = neededAyahs[nextIndex++];
          late final Future<void> future;
          future = downloadSingleAyah(
            reciterId: reciterId,
            surahNum: surahNum,
            ayahNum: ayahNum,
            cancelToken: cancelToken,
          ).then((success) {
            if (success) {
              completedCount++;
              onProgress?.call(completedCount, totalAyahs);
            }
          }).whenComplete(() {
            activeFutures.remove(future);
          });
          activeFutures.add(future);
        }

        if (activeFutures.isNotEmpty) {
          await Future.any(activeFutures);
        }
      }
    } finally {
      _activeCancelTokens.remove(key);
    }
  }

  /// Cancels an ongoing surah download job.
  void cancelSurahDownload(String reciterId, int surahNum) {
    final key = _key(reciterId, surahNum);
    final token = _activeCancelTokens[key];
    if (token != null && !token.isCancelled) {
      token.cancel('User cancelled download');
      _activeCancelTokens.remove(key);
    }
  }

  /// Checks whether a download is actively running for this surah.
  bool isSurahDownloading(String reciterId, int surahNum) {
    final key = _key(reciterId, surahNum);
    return _activeCancelTokens.containsKey(key);
  }

  // ---------------------------------------------------------------------------
  // Deletion & Storage Management
  // ---------------------------------------------------------------------------

  /// Deletes all downloaded audio files for a surah and clears its index.
  Future<void> deleteSurah(String reciterId, int surahNum) async {
    cancelSurahDownload(reciterId, surahNum);

    if (_baseStoragePath == null) await init();
    final dirPath = _getSurahDirPath(reciterId, surahNum);
    final dir = Directory(dirPath);

    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (e) {
        debugPrint('Error deleting surah directory: $e');
      }
    }

    final key = _key(reciterId, surahNum);
    _downloadIndex.remove(key);
    indexRevisionNotifier.value++;
  }

  /// Deletes a single downloaded ayah file.
  Future<void> deleteAyah(String reciterId, int surahNum, int ayahNum) async {
    if (_baseStoragePath == null) await init();
    final filePath = _getAyahFilePath(reciterId, surahNum, ayahNum);
    final file = File(filePath);

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Error deleting ayah file: $e');
      }
    }

    final key = _key(reciterId, surahNum);
    _downloadIndex[key]?.remove(ayahNum);
    if (_downloadIndex[key]?.isEmpty ?? false) {
      _downloadIndex.remove(key);
    }
    indexRevisionNotifier.value++;
  }

  /// Calculates the disk size in bytes for a downloaded surah.
  Future<int> getSurahSizeBytes(String reciterId, int surahNum) async {
    if (_baseStoragePath == null) await init();
    final dir = Directory(_getSurahDirPath(reciterId, surahNum));
    if (!await dir.exists()) return 0;

    int total = 0;
    try {
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }

  /// Calculates the total disk space consumed by all downloaded Quran audios.
  Future<int> getTotalStorageBytes() async {
    if (_baseStoragePath == null) await init();
    final baseDir = Directory(_baseStoragePath!);
    if (!await baseDir.exists()) return 0;

    int total = 0;
    try {
      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          total += await entity.length();
        }
      }
    } catch (_) {}
    return total;
  }

  /// Deletes all downloaded audio across all reciters and clears the index.
  Future<void> deleteAllDownloads() async {
    for (final token in _activeCancelTokens.values) {
      if (!token.isCancelled) token.cancel();
    }
    _activeCancelTokens.clear();

    if (_baseStoragePath == null) await init();
    final baseDir = Directory(_baseStoragePath!);
    if (await baseDir.exists()) {
      try {
        await baseDir.delete(recursive: true);
        await baseDir.create(recursive: true);
      } catch (e) {
        debugPrint('Error deleting all downloads: $e');
      }
    }

    _downloadIndex.clear();
    indexRevisionNotifier.value++;
  }

  /// Returns a detailed breakdown of all downloaded surahs on disk.
  Future<List<DownloadedSurahDetail>> getDownloadedSurahsDetails() async {
    if (_baseStoragePath == null) await init();
    final List<DownloadedSurahDetail> list = [];

    final reciterMap = {
      for (final r in QuranAudioService.availableReciters) r.id: r.name,
    };

    for (final entry in _downloadIndex.entries) {
      final parts = entry.key.split(':');
      if (parts.length != 2) continue;
      final reciterId = parts[0];
      final surahNum = int.tryParse(parts[1]);
      if (surahNum == null || surahNum < 1 || surahNum > 114) continue;

      final ayahsList = entry.value.toList()..sort();
      if (ayahsList.isEmpty) continue;

      final reciterName = reciterMap[reciterId] ?? reciterId;
      final surahName = quran.getSurahNameArabic(surahNum);
      final totalAyahs = quran.getVerseCount(surahNum);
      final sizeBytes = await getSurahSizeBytes(reciterId, surahNum);

      list.add(DownloadedSurahDetail(
        reciterId: reciterId,
        reciterName: reciterName,
        surahNumber: surahNum,
        surahName: surahName,
        totalAyahs: totalAyahs,
        downloadedAyahsCount: ayahsList.length,
        downloadedAyahs: ayahsList,
        sizeBytes: sizeBytes,
      ));
    }

    list.sort((a, b) {
      final reciterComp = a.reciterName.compareTo(b.reciterName);
      if (reciterComp != 0) return reciterComp;
      return a.surahNumber.compareTo(b.surahNumber);
    });

    return list;
  }

  /// Formats byte sizes into human readable strings (MB/KB).
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 ميجابايت';
    if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb كيلوبايت';
    }
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb ميجابايت';
  }
}
