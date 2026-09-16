import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/home/domain/services/daily_ayah_service.dart';
import 'package:siraty/features/home/domain/services/daily_ayah_widget_service.dart';

void main() {
  testWidgets('DailyAyahWidgetCard renders with zero overflow', (WidgetTester tester) async {
    const ayah = DailyAyahModel(
      surahNumber: 14,
      ayahNumber: 7,
      surahName: 'إبراهيم',
      verseText: 'وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ ۖ وَلَئِن كَفَرْتُمْ إِنَّ عَذَابِي لَشَدِيدٌ',
    );

    tester.view.physicalSize = const Size(360, 160);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DailyAyahWidgetCard(
            ayah: ayah,
            arabicAyah: '٧',
          ),
        ),
      ),
    );

    expect(find.byType(DailyAyahWidgetCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
