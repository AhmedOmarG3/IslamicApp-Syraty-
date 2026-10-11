import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/services/haptic_service.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/core/widgets/islamic_share_card_dialog.dart';
import 'package:siraty/features/azkar/data/datasource/azkar_local_data_source.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/domain/entities/zekr_item_entity.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class AzkarPage extends StatefulWidget {
  final String? initialTab;
  const AzkarPage({super.key, this.initialTab});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  bool _isLoading = true;
  List<AzkarModel> _allAzkar = [];

  // Selected daily tab
  late String _selectedTab;

  final List<String> _tabs = [
    'أذكار الصباح',
    'أذكار المساء',
    'بعد الصلاة',
    'أذكار النوم',
    'الاستيقاظ',
  ];

  // Map of remaining count for each zekr: key = "${tabName}_${itemIndex}", value = remaining count
  final Map<String, int> _remainingCounts = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null && _tabs.contains(widget.initialTab)) {
      _selectedTab = widget.initialTab!;
    } else {
      final hour = DateTime.now().hour;
      _selectedTab = (hour >= 4 && hour < 16) ? 'أذكار الصباح' : 'أذكار المساء';
    }
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    try {
      final dataSource = getIt<AzkarLocalDataSource>();
      final list = await dataSource.getAllAzkar();
      if (mounted) {
        setState(() {
          _allAzkar = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Gets the zekr items belonging to the active tab
  List<ZekrItemEntity> _getItemsForCurrentTab() {
    if (_allAzkar.isEmpty) return [];

    switch (_selectedTab) {
      case 'أذكار الصباح':
        final cat = _allAzkar.firstWhere(
          (c) => c.category == 'أذكار الصباح',
          orElse: () => _allAzkar.firstWhere(
            (c) => c.category.contains('الصباح'),
            orElse: () => _allAzkar.first,
          ),
        );
        return cat.zekrItems;

      case 'أذكار المساء':
        final cat = _allAzkar.firstWhere(
          (c) => c.category == 'أذكار المساء',
          orElse: () => _allAzkar.firstWhere(
            (c) => c.category.contains('المساء'),
            orElse: () => _allAzkar.length > 1 ? _allAzkar[1] : _allAzkar.first,
          ),
        );
        return cat.zekrItems;

      case 'بعد الصلاة':
        final cat = _allAzkar.firstWhere(
          (c) =>
              c.category.contains('بعد السلام') ||
              c.category.contains('بعد الصلاة'),
          orElse: () => _allAzkar.length > 26 ? _allAzkar[26] : _allAzkar.first,
        );
        return cat.zekrItems;

      case 'أذكار النوم':
        final cat = _allAzkar.firstWhere(
          (c) => c.category == 'أذكار النوم' || c.category.contains('النوم'),
          orElse: () => _allAzkar.length > 1 ? _allAzkar[1] : _allAzkar.first,
        );
        return cat.zekrItems;

      case 'الاستيقاظ':
        final cat = _allAzkar.firstWhere(
          (c) => c.category.contains('الاستيقاظ'),
          orElse: () => _allAzkar.length > 2 ? _allAzkar[2] : _allAzkar.first,
        );
        return cat.zekrItems;

      default:
        return _allAzkar.first.zekrItems;
    }
  }

  int _getRemaining(int index, int targetCount) {
    final key = '${_selectedTab}_$index';
    return _remainingCounts[key] ?? targetCount;
  }

  void _decrement(int index, int targetCount) {
    final key = '${_selectedTab}_$index';
    final current = _getRemaining(index, targetCount);
    if (current > 0) {
      getIt<HapticService>().triggerTap();
      setState(() {
        _remainingCounts[key] = current - 1;
      });
      if (current - 1 == 0) {
        getIt<HapticService>().triggerCompletion();
      }
    }
  }

  void _resetZekr(int index, int targetCount) {
    final key = '${_selectedTab}_$index';
    setState(() {
      _remainingCounts[key] = targetCount;
    });
  }

  void _resetAllCurrentTab(List<ZekrItemEntity> items) {
    setState(() {
      for (int i = 0; i < items.length; i++) {
        final key = '${_selectedTab}_$i';
        _remainingCounts.remove(key);
      }
    });
    getIt<HapticService>().triggerTap();
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ الذِكر إلى الحافظة',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.sageGreenDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _shareZekr(ZekrItemEntity item) {
    IslamicShareCardDialog.show(
      context,
      type: ShareCardType.zikr,
      contentText: item.text,
      title: _selectedTab,
      subtitle: item.count > 1 ? 'التكرار: ${QuranMetadata.toArabicDigits(item.count)} مرات' : null,
      source: 'أذكار المسلم',
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentItems = _getItemsForCurrentTab();

    // Calculate completion progress
    int completedCount = 0;
    for (int i = 0; i < currentItems.length; i++) {
      final target = currentItems[i].count > 0 ? currentItems[i].count : 1;
      if (_getRemaining(i, target) == 0) {
        completedCount++;
      }
    }
    final progressFraction =
        currentItems.isEmpty ? 0.0 : (completedCount / currentItems.length);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'الأذكار اليومية',
        subtitle: 'حصن المسلم ورقية النفس',
      ),
      body: _isLoading
          ? const AzkarListSkeleton()
          : Column(
              children: [
                SizedBox(height: 6.h),

                // Routine Tabs Row
                SizedBox(
                  height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = tab == _selectedTab;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedTab = tab),
                        child: Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.sageGreen
                                    : AppColors.navPillActiveLight)
                                : (isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.sageGreen
                                      : AppColors.borderGold)
                                  : (isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.borderLight),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tab,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.bgDark
                                      : const Color(0xFF13362A))
                                  : (isDark
                                      ? AppColors.textWhite
                                      : AppColors.textDarkPrimary),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),

                // Daily Progress Bar Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إنجاز $_selectedTab',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textDarkPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${QuranMetadata.toArabicDigits(completedCount)} من ${QuranMetadata.toArabicDigits(currentItems.length)}',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (completedCount > 0) ...[
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () =>
                                        _resetAllCurrentTab(currentItems),
                                    child: Icon(
                                      Icons.restart_alt_rounded,
                                      size: 18.r,
                                      color: isDark
                                          ? AppColors.textDimmed
                                          : AppColors.textDarkMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            minHeight: 6.h,
                            backgroundColor: isDark
                                ? AppColors.cardHighlight
                                : const Color(0xFFEADBCE),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressFraction == 1.0
                                  ? AppColors.successGreen
                                  : AppColors.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Azkar Cards List
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    itemCount: currentItems.length,
                    itemBuilder: (context, index) {
                      final item = currentItems[index];
                      final targetCount = item.count > 0 ? item.count : 1;
                      final remaining = _getRemaining(index, targetCount);
                      final isDone = remaining == 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 14.h),
                        decoration: BoxDecoration(
                          color: isDone
                              ? (isDark
                                  ? const Color(0xFF132A22)
                                  : const Color(0xFFF3FAF6))
                              : (isDark ? AppColors.cardDark : AppColors.cardLight),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: isDone
                                ? AppColors.successGreen.withValues(alpha: 0.35)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.borderLight),
                            width: isDone ? 1.2 : 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () => _decrement(index, targetCount),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: Item Index + Target count badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 28.r,
                                        height: 28.r,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isDone
                                              ? AppColors.successGreen.withValues(alpha: 0.15)
                                              : (isDark
                                                  ? AppColors.cardHighlight
                                                  : AppColors.iconBgCircleLight),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          QuranMetadata.toArabicDigits(index + 1),
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDone
                                                ? AppColors.successGreen
                                                : (isDark
                                                    ? AppColors.sageGreen
                                                    : AppColors.sageGreenDark),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 3.5.h),
                                        decoration: BoxDecoration(
                                          color: isDone
                                              ? AppColors.successGreen.withValues(alpha: 0.15)
                                              : (isDark
                                                  ? AppColors.cardHighlight
                                                  : const Color(0xFFF3EFE8)),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Text(
                                          isDone
                                              ? 'مُكتمَل ✓'
                                              : '${QuranMetadata.toArabicDigits(targetCount)} ${targetCount > 1 ? "مرات" : "مرة"}',
                                          style: TextStyle(
                                            color: isDone
                                                ? AppColors.successGreen
                                                : (isDark
                                                    ? AppColors.accentGoldLight
                                                    : AppColors.accentGold),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Zekr Text: Clear, open, readable Arabic typography
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    child: Text(
                                      item.text,
                                      textAlign: TextAlign.start,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        height: 1.95,
                                        letterSpacing: 0.15,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? AppColors.textWhite
                                            : const Color(0xFF1A2621),
                                      ),
                                    ),
                                  ),

                                  // Counter Button and Action Row
                                  Row(
                                    children: [
                                      // Calm, tactile Tap Counter
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(12.r),
                                            onTap: () => _decrement(index, targetCount),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 150),
                                              padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
                                              decoration: BoxDecoration(
                                                color: isDone
                                                    ? AppColors.successGreen.withValues(alpha: 0.15)
                                                    : (isDark
                                                        ? AppColors.cardDarkElevated
                                                        : const Color(0xFFF4F1EA)),
                                                borderRadius: BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: isDone
                                                      ? AppColors.successGreen.withValues(alpha: 0.35)
                                                      : (isDark
                                                          ? Colors.white.withValues(alpha: 0.08)
                                                          : AppColors.borderLight),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    isDone
                                                        ? Icons.check_circle_rounded
                                                        : Icons.touch_app_outlined,
                                                    size: 18.r,
                                                    color: isDone
                                                        ? AppColors.successGreen
                                                        : AppColors.accentGold,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    isDone
                                                        ? 'تم بحمد الله'
                                                        : 'المتبقي: ${QuranMetadata.toArabicDigits(remaining)}',
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDone
                                                          ? AppColors.successGreen
                                                          : (isDark
                                                              ? AppColors.textWhite
                                                              : AppColors.textDarkPrimary),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),

                                      // Single item reset
                                      if (remaining < targetCount)
                                        IconButton(
                                          tooltip: 'إعادة العداد',
                                          icon: Icon(
                                            Icons.refresh_rounded,
                                            size: 19.r,
                                            color: AppColors.accentGold,
                                          ),
                                          onPressed: () =>
                                              _resetZekr(index, targetCount),
                                        ),

                                      // Copy
                                      IconButton(
                                        tooltip: 'نسخ',
                                        icon: Icon(
                                          Icons.copy_rounded,
                                          size: 17.r,
                                          color: isDark
                                              ? AppColors.textDimmed
                                              : AppColors.textDarkMuted,
                                        ),
                                        onPressed: () => _copyText(item.text),
                                      ),

                                      // Share
                                      IconButton(
                                        tooltip: 'مشاركة',
                                        icon: Icon(
                                          Icons.share_outlined,
                                          size: 17.r,
                                          color: isDark
                                              ? AppColors.textDimmed
                                              : AppColors.textDarkMuted,
                                        ),
                                        onPressed: () => _shareZekr(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
