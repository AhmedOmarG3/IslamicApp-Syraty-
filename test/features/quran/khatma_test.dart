import 'package:flutter_test/flutter_test.dart';
import 'package:siraty/features/quran/domain/entities/khatma_model.dart';

void main() {
  group('KhatmaModel Unit Tests', () {
    test('Calculates 30-day khatma daily pages accurately', () {
      final khatma = KhatmaModel(
        id: 'test_1',
        title: 'ختمة ٣٠ يوماً',
        targetDays: 30,
        startDate: DateTime.now(),
        startPage: 1,
        currentPage: 1,
      );

      expect(khatma.totalPages, 604);
      expect(khatma.dailyPagesTarget, 21); // (604 / 30).ceil() = 21 pages/day
      expect(khatma.currentDayNumber, 1);
      expect(khatma.isCompleted, false);

      final (startP, endP) = khatma.todayWirdRange;
      expect(startP, 1);
      expect(endP, 21);
      expect(khatma.isTodayWirdDone, false);
    });

    test('Progress Ratio and Wird Completion Status', () {
      final khatma = KhatmaModel(
        id: 'test_2',
        title: 'ختمة ٣٠ يوماً',
        targetDays: 30,
        startDate: DateTime.now(),
        startPage: 1,
        currentPage: 25, // Passed today's 21 pages
        lastReadDate: DateTime.now(),
      );

      expect(khatma.pagesRead, 25);
      expect(khatma.isTodayWirdDone, true);
      expect(khatma.progressRatio, closeTo(25 / 604, 0.001));
    });

    test('Sequential wird progression: misses day, remains on same unread wird', () {
      // User started 2 days ago, but never read or completed anything
      final khatma = KhatmaModel(
        id: 'test_seq',
        title: 'ختمة ٣٠ يوماً',
        targetDays: 30,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        startPage: 1,
        currentPage: 1,
        lastReadDate: null,
      );

      // Must NOT skip to day 3! Must wait for them at page 1..21
      final (startP, endP) = khatma.todayWirdRange;
      expect(startP, 1);
      expect(endP, 21);
      expect(khatma.isTodayWirdDone, false);
    });

    test('Completes when reaching page 604', () {
      final khatma = KhatmaModel(
        id: 'test_3',
        title: 'ختمة منتهية',
        targetDays: 30,
        startDate: DateTime.now().subtract(const Duration(days: 29)),
        startPage: 1,
        currentPage: 604,
      );

      expect(khatma.isCompleted, true);
      expect(khatma.remainingPages, 0);
    });

    test('Serialization to and from JSON preserves integrity', () {
      final now = DateTime.now();
      final model = KhatmaModel(
        id: 'khatma_json_test',
        title: 'ختمة شهرين',
        targetDays: 60,
        startDate: now,
        startPage: 100,
        currentPage: 120,
      );

      final json = model.toJson();
      final revived = KhatmaModel.fromJson(json);

      expect(revived.id, model.id);
      expect(revived.title, model.title);
      expect(revived.targetDays, 60);
      expect(revived.startPage, 100);
      expect(revived.currentPage, 120);
      expect(revived.totalPages, 505); // 604 - 100 + 1 = 505
      expect(revived.reminderEnabled, true);
      expect(revived.reminderHour, 21);
      expect(revived.reminderMinute, 0);
      expect(revived.reminderFormattedTime, '9:00 م');
    });

    test('Editing Khatma preserves current page and updates pace accurately', () {
      final initial = KhatmaModel(
        id: 'test_edit',
        title: 'ختمة ٣٠ يوماً',
        targetDays: 30,
        startDate: DateTime.now().subtract(const Duration(days: 6)),
        startPage: 1,
        currentPage: 140, // reached page 140
        lastReadDate: DateTime.now(),
      );

      expect(initial.pagesRead, 140);
      expect(initial.currentPage, 140);

      // User changes to 10 pages per day
      final updated = initial.copyWith(
        customDailyPages: 10,
        title: 'ختمة ١٠ صفحات يومياً',
        targetDays: 52,
        reminderHour: 6,
        reminderMinute: 0,
      );

      // Progress is preserved
      expect(updated.startPage, 1);
      expect(updated.currentPage, 140);
      expect(updated.pagesRead, 140);
      expect(updated.dailyPagesTarget, 10);
      expect(updated.reminderHour, 6);
      expect(updated.reminderFormattedTime, '6:00 ص');

      // Next wird starts at page 141 and reads 10 pages (141..150)
      final (startP, endP) = updated.nextWirdRange;
      expect(startP, 141);
      expect(endP, 150);
    });
  });
}
