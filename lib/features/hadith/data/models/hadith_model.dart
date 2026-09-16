import 'package:equatable/equatable.dart';

class HadithModel extends Equatable {
  final int id;
  final String title;
  final String narrator;
  final String arabic;
  final String source;
  final String book;
  final String category;
  final String chapter;
  final int chapterId;
  final String explanation;

  const HadithModel({
    required this.id,
    required this.title,
    required this.narrator,
    required this.arabic,
    required this.source,
    this.book = 'صحيح البخاري',
    required this.category,
    this.chapter = '',
    this.chapterId = 0,
    required this.explanation,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int id = rawId is num
        ? rawId.toInt()
        : (rawId is String ? (int.tryParse(rawId) ?? 0) : 0);
    final src = json['source'] as String? ?? '';
    var resolvedBook = json['book'] as String?;
    if (resolvedBook == null || resolvedBook.isEmpty) {
      if (src.contains('مسلم') && !src.contains('البخاري')) {
        resolvedBook = 'صحيح مسلم';
      } else if (src.contains('البخاري')) {
        resolvedBook = 'صحيح البخاري';
      } else {
        resolvedBook = 'الأربعون النووية';
      }
    }

    final rawArabic = (json['arabic'] as String?) ?? (json['text'] as String?) ?? '';
    final rawChapter = json['chapter'] as String?;
    final rawCategory = json['category'] as String?;
    final resolvedChapter = rawChapter ?? rawCategory ?? 'عام';
    final resolvedCategory = rawCategory ?? rawChapter ?? 'عام';
    final rawChapterId = json['chapterId'];
    final int chapterId = rawChapterId is num
        ? rawChapterId.toInt()
        : (rawChapterId is String ? (int.tryParse(rawChapterId) ?? 0) : 0);


    final rawTitle = json['title'] as String? ?? '';
    final title = rawTitle.isNotEmpty
        ? rawTitle
        : (id > 0 ? 'حديث رقم $id' : resolvedChapter);

    return HadithModel(
      id: id,
      title: title,
      narrator: json['narrator'] as String? ?? '',
      arabic: rawArabic,
      source: src.isNotEmpty ? src : resolvedBook,
      book: resolvedBook,
      category: resolvedCategory,
      chapter: resolvedChapter,
      chapterId: chapterId,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'narrator': narrator,
      'arabic': arabic,
      'source': source,
      'book': book,
      'category': category,
      'chapter': chapter,
      'chapterId': chapterId,
      'explanation': explanation,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        narrator,
        arabic,
        source,
        book,
        category,
        chapter,
        chapterId,
        explanation,
      ];
}

