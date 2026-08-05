import 'package:siraty/features/quran/domain/entities/verse_entity.dart';

class VerseModel extends VerseEntity {
  const VerseModel({
    required super.chapter,
    required super.verse,
    required super.text,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      chapter: json['chapter'],
      verse: json['verse'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }
}
