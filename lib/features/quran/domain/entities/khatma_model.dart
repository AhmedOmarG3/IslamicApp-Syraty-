import 'package:equatable/equatable.dart';

class KhatmaModel extends Equatable {
  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  final int startPage;
  final int currentPage;
  final DateTime? completedAt;
  final DateTime? lastReadDate;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final int? customDailyPages;

  const KhatmaModel({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    this.startPage = 1,
    this.currentPage = 1,
    this.completedAt,
    this.lastReadDate,
    this.reminderEnabled = true,
    this.reminderHour = 21,
    this.reminderMinute = 0,
    this.customDailyPages,
  });

  /// Total pages included in this Khatma (normally 604 - startPage + 1)
  int get totalPages => (604 - startPage + 1).clamp(1, 604);

  /// Pages read so far from startPage
  int get pagesRead {
    if (lastReadDate == null && currentPage <= startPage) return 0;
    return (currentPage - startPage + 1).clamp(0, totalPages);
  }

  /// Progress percentage [0.0 .. 1.0]
  double get progressRatio => (pagesRead / totalPages).clamp(0.0, 1.0);

  /// Remaining pages to reach page 604
  int get remainingPages {
    if (lastReadDate == null && currentPage <= startPage) return totalPages;
    return (604 - currentPage).clamp(0, 604);
  }

  /// Days elapsed since startDate (1-indexed)
  int get currentDayNumber {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = today.difference(start).inDays + 1;
    return diff.clamp(1, targetDays);
  }

  /// Days remaining in the planned duration
  int get remainingDays => (targetDays - currentDayNumber).clamp(0, targetDays);

  /// Base daily pages target
  int get dailyPagesTarget {
    if (customDailyPages != null && customDailyPages! > 0) {
      return customDailyPages!.clamp(1, 604);
    }
    if (targetDays <= 0) return 20;
    return (totalPages / targetDays).ceil().clamp(1, 604);
  }

  /// Whether the entire Mushaf has been completed
  bool get isCompleted => currentPage >= 604 || completedAt != null;

  /// Calculate the active wird page range (startPage, endPage)
  /// Crucial: If the user didn't complete the previous wird, it waits for them!
  /// It only advances to the next pages when the user marks the previous wird done.
  (int start, int end) get todayWirdRange {
    final daily = dailyPagesTarget;
    // 1. If user hasn't completed any wird yet (newly started Khatma)
    if (lastReadDate == null && currentPage <= startPage) {
      final startP = startPage.clamp(1, 604);
      final endP = (startP + daily - 1).clamp(1, 604);
      return (startP, endP);
    }

    // 2. If today's wird is already marked done, return the range that was completed today
    if (isTodayWirdDone) {
      final endP = currentPage.clamp(1, 604);
      final startP = (endP - daily + 1).clamp(startPage, 604);
      return (startP, endP);
    }

    // 3. Active wird waiting to be read (starts right after the last completed page)
    final startP = (currentPage + 1).clamp(1, 604);
    final endP = (startP + daily - 1).clamp(1, 604);
    return (startP, endP);
  }

  /// Next upcoming wird range (for extra wird / tomorrow's wird ahead of time)
  (int start, int end) get nextWirdRange {
    final daily = dailyPagesTarget;
    final startP = (currentPage + 1).clamp(1, 604);
    final endP = (startP + daily - 1).clamp(1, 604);
    return (startP, endP);
  }

  /// Whether today's wird has been fulfilled
  bool get isTodayWirdDone {
    if (isCompleted) return true;
    if (lastReadDate == null) return false;
    final now = DateTime.now();
    return lastReadDate!.year == now.year &&
        lastReadDate!.month == now.month &&
        lastReadDate!.day == now.day;
  }

  String get reminderFormattedTime {
    final hour12 = reminderHour == 0 ? 12 : (reminderHour > 12 ? reminderHour - 12 : reminderHour);
    final period = reminderHour >= 12 ? 'م' : 'ص';
    final minuteStr = reminderMinute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  KhatmaModel copyWith({
    String? id,
    String? title,
    int? targetDays,
    DateTime? startDate,
    int? startPage,
    int? currentPage,
    DateTime? completedAt,
    DateTime? lastReadDate,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? customDailyPages,
  }) {
    return KhatmaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      startPage: startPage ?? this.startPage,
      currentPage: currentPage ?? this.currentPage,
      completedAt: completedAt ?? this.completedAt,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      customDailyPages: customDailyPages ?? this.customDailyPages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetDays': targetDays,
        'startDate': startDate.toIso8601String(),
        'startPage': startPage,
        'currentPage': currentPage,
        'completedAt': completedAt?.toIso8601String(),
        'lastReadDate': lastReadDate?.toIso8601String(),
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'customDailyPages': customDailyPages,
      };

  factory KhatmaModel.fromJson(Map<String, dynamic> json) {
    return KhatmaModel(
      id: json['id'] as String? ?? 'khatma_1',
      title: json['title'] as String? ?? 'ختمة القرآن الكريم',
      targetDays: json['targetDays'] as int? ?? 30,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      startPage: json['startPage'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? 1,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.tryParse(json['lastReadDate'] as String)
          : null,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int? ?? 21,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      customDailyPages: json['customDailyPages'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        targetDays,
        startDate,
        startPage,
        currentPage,
        completedAt,
        lastReadDate,
        reminderEnabled,
        reminderHour,
        reminderMinute,
        customDailyPages,
      ];
}
