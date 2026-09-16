import 'package:equatable/equatable.dart';
import 'package:siraty/features/quran/domain/entities/verse_entity.dart';

/// Represents a continuous sequence of verses belonging to a single Surah on a Mushaf page.
class MushafPageSegment extends Equatable {
  final int surahNumber;
  final String surahName;
  final bool isMakki;
  final bool isSurahStart;
  final List<VerseEntity> verses;

  const MushafPageSegment({
    required this.surahNumber,
    required this.surahName,
    required this.isMakki,
    required this.isSurahStart,
    required this.verses,
  });

  @override
  List<Object?> get props => [
        surahNumber,
        surahName,
        isMakki,
        isSurahStart,
        verses,
      ];
}

/// Domain entity representing an authoritative 604-page Madinah Mushaf page.
class MushafPage extends Equatable {
  final int pageNumber; // 1 to 604
  final int juzNumber; // 1 to 30
  final List<MushafPageSegment> segments;

  const MushafPage({
    required this.pageNumber,
    required this.juzNumber,
    required this.segments,
  });

  /// Primary Surah name for the page header (first segment's surah)
  String get primarySurahName =>
      segments.isNotEmpty ? segments.first.surahName : '';

  /// All unique Surah names appearing on this page
  List<String> get allSurahNames =>
      segments.map((s) => s.surahName).toSet().toList();

  /// Total count of verses on this page
  int get totalVersesCount =>
      segments.fold(0, (sum, seg) => sum + seg.verses.length);

  /// Check if a specific verse exists on this page
  bool containsVerse(int surahNumber, int ayahNumber) {
    for (final segment in segments) {
      if (segment.surahNumber == surahNumber) {
        for (final verse in segment.verses) {
          if (verse.verse == ayahNumber) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Get a verse by surah number and ayah number if present on this page
  VerseEntity? getVerse(int surahNumber, int ayahNumber) {
    for (final segment in segments) {
      if (segment.surahNumber == surahNumber) {
        for (final verse in segment.verses) {
          if (verse.verse == ayahNumber) {
            return verse;
          }
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [pageNumber, juzNumber, segments];
}
