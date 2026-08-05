import 'package:equatable/equatable.dart';
import 'package:siraty/features/quran/domain/entities/verse_entity.dart';

class SurahEntity extends Equatable {
  final int surahNumber;
  final String surahName;
  final List<VerseEntity> verses;

  const SurahEntity({
    required this.surahNumber,
    required this.surahName,
    required this.verses,
  });

  @override
  List<Object?> get props => [surahNumber, surahName, verses];
}
