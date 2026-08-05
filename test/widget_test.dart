import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/app/app.dart';

void main() {
  testWidgets('SiratyApp smoke test', (WidgetTester tester) async {
    expect(const SiratyApp(), isNotNull);
  });
}
