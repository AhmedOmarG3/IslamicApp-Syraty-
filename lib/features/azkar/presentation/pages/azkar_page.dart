import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:siraty/app/di/service_locator.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/app_skeleton.dart';
import 'package:siraty/features/azkar/data/datasource/azkar_local_data_source.dart';
import 'package:siraty/features/azkar/data/models/azkar_model.dart';
import 'package:siraty/features/azkar/domain/entities/zekr_item_entity.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  bool _isLoading = true;
  List<AzkarModel> _allAzkar = [];

  // Selected daily tab
  String _selectedTab = 'أذكار الصباح';

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
          (c) => c.category.contains('الصباح'),
          orElse: () => _allAzkar.first,
        );
        return cat.zekrItems;

      case 'أذكار المساء':
        final cat = _allAzkar.firstWhere(
          (c) => c.category.contains('المساء'),
          orElse: () => _allAzkar.first,
        );
        return cat.zekrItems;

      case 'بعد الصلاة':
        final cat = _allAzkar.firstWhere(
          (c) => c.category.contains('بعد السلام') || c.category.contains('بعد الصلاة'),
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
      HapticFeedback.lightImpact();
      setState(() {
        _remainingCounts[key] = current - 1;
      });
      if (current - 1 == 0) {
        HapticFeedback.mediumImpact();
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
    HapticFeedback.mediumImpact();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _shareText(String text) {
    Share.share(
      '$text\n\n[$_selectedTab · سِيرتي]',
      subject: _selectedTab,
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
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.sageGreen : AppColors.navPillActiveLight)
                                : (isDark ? AppColors.cardDark : AppColors.cardLight),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.sageGreen : AppColors.borderGold)
                                  : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tab,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? (isDark ? AppColors.bgDark : const Color(0xFF13362A))
                                  : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
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
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
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
                                    onTap: () => _resetAllCurrentTab(currentItems),
                                    child: Icon(
                                      Icons.restart_alt_rounded,
                                      size: 18.r,
                                      color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
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
                            backgroundColor: isDark ? AppColors.cardHighlight : const Color(0xFFEADBCE),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressFraction == 1.0 ? AppColors.successGreen : AppColors.accentGold,
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    itemCount: currentItems.length,
                    itemBuilder: (context, index) {
                      final item = currentItems[index];
                      final targetCount = item.count > 0 ? item.count : 1;
                      final remaining = _getRemaining(index, targetCount);
                      final isDone = remaining == 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 14.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: isDone
                                ? AppColors.successGreen
                                : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                            width: isDone ? 1.4 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Item Index + Target count badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    QuranMetadata.toArabicDigits(index + 1),
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.successGreen.withValues(alpha: 0.15)
                                        : (isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isDone
                                          ? AppColors.successGreen
                                          : AppColors.accentGold.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isDone
                                        ? 'مُكتمَل'
                                        : '${QuranMetadata.toArabicDigits(targetCount)} ${targetCount > 1 ? "مرات" : "مرة"}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDone ? AppColors.successGreen : AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            // Zekr Text
                            SelectableText(
                              item.text,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 16.sp,
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                                height: 1.85,
                                fontFamily: AppTextStyles.fontFamilyAmiri,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Counter Button and Action Row
                            Row(
                              children: [
                                // Large Tap Counter
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _decrement(index, targetCount),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppColors.successGreen
                                            : (isDark
                                                ? AppColors.sageGreenContainer
                                                : const Color(0xFF13362A)),
                                        borderRadius: BorderRadius.circular(14.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isDone
                                                ? Icons.check_circle_rounded
                                                : Icons.touch_app_rounded,
                                            size: 20.r,
                                            color: isDone
                                                ? Colors.white
                                                : (isDark ? AppColors.sageGreen : AppColors.accentGold),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            isDone
                                                ? 'تم بحمد الله'
                                                : 'المتبقي: ${QuranMetadata.toArabicDigits(remaining)}',
                                            style: AppTextStyles.titleSmall.copyWith(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDone
                                                  ? Colors.white
                                                  : (isDark ? AppColors.sageGreen : Colors.white),
                                            ),
                                          ),
                                        ],
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
                                      size: 20.r,
                                      color: AppColors.accentGold,
                                    ),
                                    onPressed: () => _resetZekr(index, targetCount),
                                  ),

                                // Copy
                                IconButton(
                                  tooltip: 'نسخ',
                                  icon: Icon(
                                    Icons.copy_rounded,
                                    size: 18.r,
                                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                                  ),
                                  onPressed: () => _copyText(item.text),
                                ),

                                // Share
                                IconButton(
                                  tooltip: 'مشاركة',
                                  icon: Icon(
                                    Icons.share_outlined,
                                    size: 18.r,
                                    color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                                  ),
                                  onPressed: () => _shareText(item.text),
                                ),
                              ],
                            ),
                          ],
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
