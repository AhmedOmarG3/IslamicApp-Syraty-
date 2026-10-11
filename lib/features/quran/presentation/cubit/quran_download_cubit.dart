import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_download_state.dart';

export 'package:siraty/features/quran/presentation/cubit/quran_download_state.dart';

class QuranDownloadCubit extends Cubit<QuranDownloadState> {
  final QuranDownloadService _downloadService;

  QuranDownloadCubit({required QuranDownloadService downloadService})
      : _downloadService = downloadService,
        super(const QuranDownloadState()) {
    _downloadService.indexRevisionNotifier.addListener(_onIndexUpdated);
  }

  void _onIndexUpdated() {
    emit(state.copyWith(revision: state.revision + 1));
  }

  static String _key(String reciterId, int surahNum) => '$reciterId:$surahNum';

  /// Get active download progress or build from indexed state.
  SurahDownloadProgress getSurahProgress({
    required String reciterId,
    required int surahNum,
    required int totalAyahs,
  }) {
    final key = _key(reciterId, surahNum);
    final existing = state.progressMap[key];
    if (existing != null) return existing;

    final completed = _downloadService.getDownloadedAyahsCount(reciterId, surahNum);
    return SurahDownloadProgress(
      reciterId: reciterId,
      surahNumber: surahNum,
      totalAyahs: totalAyahs,
      completedAyahs: completed,
      isDownloading: _downloadService.isSurahDownloading(reciterId, surahNum),
    );
  }

  bool isAyahDownloaded(String reciterId, int surahNum, int ayahNum) {
    return _downloadService.isAyahDownloaded(reciterId, surahNum, ayahNum);
  }

  bool isSurahFullyDownloaded(String reciterId, int surahNum, int totalAyahs) {
    return _downloadService.isSurahFullyDownloaded(reciterId, surahNum, totalAyahs);
  }

  int getDownloadedAyahsCount(String reciterId, int surahNum) {
    return _downloadService.getDownloadedAyahsCount(reciterId, surahNum);
  }

  Future<int> getSurahSizeBytes(String reciterId, int surahNum) {
    return _downloadService.getSurahSizeBytes(reciterId, surahNum);
  }

  /// Start downloading a surah with progress emission.
  Future<void> startSurahDownload({
    required String reciterId,
    required int surahNum,
    required int totalAyahs,
  }) async {
    final key = _key(reciterId, surahNum);
    final initialCompleted = _downloadService.getDownloadedAyahsCount(reciterId, surahNum);

    final currentMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
    currentMap[key] = SurahDownloadProgress(
      reciterId: reciterId,
      surahNumber: surahNum,
      totalAyahs: totalAyahs,
      completedAyahs: initialCompleted,
      isDownloading: true,
    );
    emit(state.copyWith(progressMap: currentMap));

    try {
      await _downloadService.downloadSurah(
        reciterId: reciterId,
        surahNum: surahNum,
        totalAyahs: totalAyahs,
        onProgress: (completed, total) {
          final updatedMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
          updatedMap[key] = SurahDownloadProgress(
            reciterId: reciterId,
            surahNumber: surahNum,
            totalAyahs: total,
            completedAyahs: completed,
            isDownloading: completed < total,
          );
          emit(state.copyWith(progressMap: updatedMap));
        },
      );

      final finalMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
      final finalCompleted = _downloadService.getDownloadedAyahsCount(reciterId, surahNum);
      finalMap[key] = SurahDownloadProgress(
        reciterId: reciterId,
        surahNumber: surahNum,
        totalAyahs: totalAyahs,
        completedAyahs: finalCompleted,
        isDownloading: false,
      );
      emit(state.copyWith(progressMap: finalMap, revision: state.revision + 1));
    } catch (e) {
      final isCancel = e is DioException && CancelToken.isCancel(e);
      final finalMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
      final finalCompleted = _downloadService.getDownloadedAyahsCount(reciterId, surahNum);
      finalMap[key] = SurahDownloadProgress(
        reciterId: reciterId,
        surahNumber: surahNum,
        totalAyahs: totalAyahs,
        completedAyahs: finalCompleted,
        isDownloading: false,
        isFailed: !isCancel,
        errorMessage: isCancel ? null : 'فشل تنزيل بعض الآيات، تحقق من اتصال الإنترنت',
      );
      emit(state.copyWith(progressMap: finalMap, revision: state.revision + 1));
    }
  }

  void cancelSurahDownload({required String reciterId, required int surahNum}) {
    _downloadService.cancelSurahDownload(reciterId, surahNum);
    final key = _key(reciterId, surahNum);
    final finalMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
    final completed = _downloadService.getDownloadedAyahsCount(reciterId, surahNum);
    final current = finalMap[key];
    if (current != null) {
      finalMap[key] = current.copyWith(
        isDownloading: false,
        completedAyahs: completed,
      );
      emit(state.copyWith(progressMap: finalMap, revision: state.revision + 1));
    }
  }

  Future<void> deleteSurah({required String reciterId, required int surahNum}) async {
    await _downloadService.deleteSurah(reciterId, surahNum);
    final key = _key(reciterId, surahNum);
    final finalMap = Map<String, SurahDownloadProgress>.from(state.progressMap);
    finalMap.remove(key);
    emit(state.copyWith(progressMap: finalMap, revision: state.revision + 1));
  }

  Future<bool> downloadSingleAyah({
    required String reciterId,
    required int surahNum,
    required int ayahNum,
  }) async {
    final success = await _downloadService.downloadSingleAyah(
      reciterId: reciterId,
      surahNum: surahNum,
      ayahNum: ayahNum,
    );
    emit(state.copyWith(revision: state.revision + 1));
    return success;
  }

  Future<void> deleteSingleAyah({
    required String reciterId,
    required int surahNum,
    required int ayahNum,
  }) async {
    await _downloadService.deleteAyah(reciterId, surahNum, ayahNum);
    emit(state.copyWith(revision: state.revision + 1));
  }

  Future<int> getTotalStorageBytes() {
    return _downloadService.getTotalStorageBytes();
  }

  Future<List<DownloadedSurahDetail>> getDownloadedSurahsDetails() {
    return _downloadService.getDownloadedSurahsDetails();
  }

  Future<void> deleteAllDownloads() async {
    await _downloadService.deleteAllDownloads();
    emit(state.copyWith(progressMap: const {}, revision: state.revision + 1));
  }

  @override
  Future<void> close() {
    _downloadService.indexRevisionNotifier.removeListener(_onIndexUpdated);
    return super.close();
  }
}
