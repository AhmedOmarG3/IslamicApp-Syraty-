import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/domain/entities/tajweed_rule.dart';

void main() {
  group('TajweedRule Entities Tests', () {
    test('TajweedExample fromJson parses accurately', () {
      final json = {
        'word': 'مِنْ قَبْلُ',
        'explanation': 'إخفاء النون الساكنة عند القاف',
      };
      final example = TajweedExample.fromJson(json);
      expect(example.word, 'مِنْ قَبْلُ');
      expect(example.explanation, 'إخفاء النون الساكنة عند القاف');
    });

    test('TajweedRule fromJson parses rule with letters and examples', () {
      final json = {
        'name': 'الإخفاء الحقيقي',
        'definition': 'النطق بالحرف بصفة بين الإظهار والإدغام',
        'letters': 'ص، ذ، ث، ك، ج، ش، ق، س، د، ط، ز، ف، ت، ض، ظ',
        'examples': [
          {
            'word': 'مِنْ قَبْلُ',
            'explanation': 'إخفاء النون الساكنة عند القاف مع الغنة',
          }
        ],
        'types': [],
      };

      final rule = TajweedRule.fromJson(json);
      expect(rule.name, 'الإخفاء الحقيقي');
      expect(rule.definition, 'النطق بالحرف بصفة بين الإظهار والإدغام');
      expect(rule.letters, contains('ص'));
      expect(rule.examples.length, 1);
      expect(rule.examples.first.word, 'مِنْ قَبْلُ');
    });

    test('TajweedCategory parses category and rules list correctly', () {
      final catJson = {
        'id': 'waqf_signs',
        'title': 'علامات الوقف ومصطلحات الضبط',
        'icon': 'pause_circle_outline',
        'description': 'علامات الوقف المعتمدة في مصحف المدينة النبوية',
        'rules': [
          {
            'name': 'الوقف اللازم (مـ)',
            'definition': 'يلزم الوقف عليه ويمتنع وصله بما بعده لئلا يفسد المعنى',
            'letters': 'مـ',
            'examples': [
              {
                'word': 'إِنَّمَا يَسْتَجِيبُ الَّذِينَ يَسْمَعُونَ ۘ',
                'explanation': 'يلزم الوقف هنا حتى لا يلتبس المعنى',
              }
            ],
            'types': [],
          }
        ],
      };

      final category = TajweedCategory.fromJson(catJson);
      expect(category.id, 'waqf_signs');
      expect(category.title, 'علامات الوقف ومصطلحات الضبط');
      expect(category.rules.length, 1);
      expect(category.rules.first.name, 'الوقف اللازم (مـ)');
      expect(category.rules.first.letters, 'مـ');
    });
  });
}
