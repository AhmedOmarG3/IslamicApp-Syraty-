class TajweedCategory {
  final String id;
  final String title;
  final String icon;
  final String description;
  final List<TajweedRule> rules;

  const TajweedCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.rules,
  });

  factory TajweedCategory.fromJson(Map<String, dynamic> json) {
    return TajweedCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? 'menu_book_rounded',
      description: json['description'] as String? ?? '',
      rules: (json['rules'] as List<dynamic>? ?? [])
          .map((r) => TajweedRule.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TajweedRule {
  final String name;
  final String definition;
  final String letters;
  final List<TajweedExample> examples;
  final List<TajweedType> types;

  const TajweedRule({
    required this.name,
    required this.definition,
    required this.letters,
    this.examples = const [],
    this.types = const [],
  });

  factory TajweedRule.fromJson(Map<String, dynamic> json) {
    return TajweedRule(
      name: json['name'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      letters: json['letters'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => TajweedExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      types: (json['types'] as List<dynamic>? ?? [])
          .map((t) => TajweedType.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TajweedType {
  final String typeName;
  final String typeLetters;
  final List<TajweedExample> examples;

  const TajweedType({
    required this.typeName,
    required this.typeLetters,
    this.examples = const [],
  });

  factory TajweedType.fromJson(Map<String, dynamic> json) {
    return TajweedType(
      typeName: json['type_name'] as String? ?? '',
      typeLetters: json['type_letters'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => TajweedExample.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TajweedExample {
  final String word;
  final String explanation;

  const TajweedExample({
    required this.word,
    required this.explanation,
  });

  factory TajweedExample.fromJson(Map<String, dynamic> json) {
    return TajweedExample(
      word: json['word'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
    );
  }
}
