import 'package:equatable/equatable.dart';
import 'package:siraty/features/quran/data/services/quran_download_service.dart';

class QuranDownloadState extends Equatable {
  final Map<String, SurahDownloadProgress> progressMap;
  final int revision;

  const QuranDownloadState({
    this.progressMap = const {},
    this.revision = 0,
  });

  QuranDownloadState copyWith({
    Map<String, SurahDownloadProgress>? progressMap,
    int? revision,
  }) {
    return QuranDownloadState(
      progressMap: progressMap ?? this.progressMap,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [progressMap, revision];
}
