import 'package:equatable/equatable.dart';

class VerseEntity extends Equatable {
  final int chapter;
  final int verse;
  final String text;

  const VerseEntity({
    required this.chapter,
    required this.verse,
    required this.text,
  });

  @override
  List<Object?> get props => [chapter, verse, text];
}
