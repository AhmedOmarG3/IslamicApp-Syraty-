class VerseModel {
  final int chapter;
  final int verse;
  final String text;

  VerseModel({
    required this.chapter,
    required this.verse,
    required this.text,
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