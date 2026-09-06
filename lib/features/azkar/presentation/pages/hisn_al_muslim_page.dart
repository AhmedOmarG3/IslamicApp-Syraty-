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
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class HisnAlMuslimPage extends StatefulWidget {
  const HisnAlMuslimPage({super.key});

  @override
  State<HisnAlMuslimPage> createState() => _HisnAlMuslimPageState();
}

class _HisnAlMuslimPageState extends State<HisnAlMuslimPage> {
  List<AzkarModel> _allCategories = [];
  List<AzkarModel> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  // Track progress of individual items: key = "${categoryId}_${itemId}", value = remaining count
  final Map<String, int> _remainingCounts = {};
  // Expanded state of category cards
  final Set<int> _expandedCategoryIds = {};

  final List<String> _filters = [
    'الكل',
    'الصباح والمساء',
    'الصلاة والمساجد',
    'الاستيقاظ والنوم',
    'السفر',
    'الهم والكرب',
    'المرض',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final dataSource = getIt<AzkarLocalDataSource>();
      final data = await dataSource.getAllAzkar();
      if (mounted) {
        setState(() {
          _allCategories = data;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    List<AzkarModel> list = _allCategories;

    // Filter by topic chip
    if (_selectedFilter != 'الكل') {
      list = list.where((cat) {
        final title = cat.category;
        switch (_selectedFilter) {
          case 'الصباح والمساء':
            return title.contains('الصباح') || title.contains('المساء');
          case 'الصلاة والمساجد':
            return title.contains('صلاة') ||
                title.contains('مسجد') ||
                title.contains('وضوء') ||
                title.contains('آذان') ||
                title.contains('تشهد');
          case 'الاستيقاظ والنوم':
            return title.contains('نوم') || title.contains('استيقاظ') || title.contains('فزع');
          case 'السفر':
            return title.contains('سفر') || title.contains('ركوب') || title.contains('دابة');
          case 'الهم والكرب':
            return title.contains('كرب') ||
                title.contains('هم') ||
                title.contains('حزن') ||
                title.contains('وسوسة') ||
                title.contains('غضب');
          case 'المرض':
            return title.contains('مرض') ||
                title.contains('مريض') ||
                title.contains('وجع') ||
                title.contains('جنازة') ||
                title.contains('ميت');
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim();
      list = list.where((cat) {
        final matchCategory = cat.category.contains(q);
        final matchDua = cat.zekrItems.any((item) => item.text.contains(q));
        return matchCategory || matchDua;
      }).toList();
    }

    _filteredCategories = list;
  }

  int _getRemainingCount(int categoryId, int itemId, int defaultCount) {
    final key = '${categoryId}_$itemId';
    return _remainingCounts[key] ?? defaultCount;
  }

  void _decrementCount(int categoryId, int itemId, int defaultCount) {
    final key = '${categoryId}_$itemId';
    final current = _getRemainingCount(categoryId, itemId, defaultCount);
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

  void _resetCount(int categoryId, int itemId, int defaultCount) {
    final key = '${categoryId}_$itemId';
    setState(() {
      _remainingCounts[key] = defaultCount;
    });
  }

  void _copyDua(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم نسخ الدعاء بنجاح',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.sageGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _shareDua(String text, String category) {
    Share.share(
      '$text\n\n[$category - حصن المسلم · سِيرتي]',
      subject: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'حصن المسلم',
        subtitle: 'أدعية وأذكار من الكتاب والسنّة',
      ),
      body: _isLoading
          ? const AzkarListSkeleton()
          : Column(
              children: [
                // Search Input Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث في ١٣٢ باباً وأدعية حصن المسلم...',
                        hintStyle: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                          size: 20.r,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18.r,
                                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _applyFilters();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ),

                // Quick Filter Chips
                SizedBox(
                  height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                            _applyFilters();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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
                            filter,
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
                SizedBox(height: 8.h),

                // Counter bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأبواب المتاحة',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                        ),
                      ),
                      Text(
                        '${QuranMetadata.toArabicDigits(_filteredCategories.length)} باب',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories & Duas List
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? Center(
                          child: Text(
                            'لم يتم العثور على أذكار مطابقة',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            final isExpanded = _expandedCategoryIds.contains(category.id);

                            return _buildCategoryCard(
                              category: category,
                              isExpanded: isExpanded,
                              isDark: isDark,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryCard({
    required AzkarModel category,
    required bool isExpanded,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isExpanded
              ? AppColors.borderGold
              : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
          width: isExpanded ? 1.2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header Tile
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategoryIds.remove(category.id);
                } else {
                  _expandedCategoryIds.add(category.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  // Chapter Number Badge
                  Container(
                    width: 36.r,
                    height: 36.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      QuranMetadata.toArabicDigits(category.id),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Category Name & Item count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.category,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${QuranMetadata.toArabicDigits(category.zekrItems.length)} أذكار / أدعية',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.sp,
                            color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/Collapse Arrow Icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                    size: 24.r,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Duas List
          if (isExpanded) ...[
            Divider(
              color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                children: category.zekrItems.map((item) {
                  final targetCount = item.count > 0 ? item.count : 1;
                  final remaining = _getRemainingCount(category.id, item.id, targetCount);
                  final isDone = remaining == 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDone
                            ? AppColors.successGreen
                            : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                        width: isDone ? 1.2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dua text
                        SelectableText(
                          item.text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16.sp,
                            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                            height: 1.8,
                            fontFamily: AppTextStyles.fontFamilyAmiri,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Action & Counter Bar
                        Row(
                          children: [
                            // Interactive Tap Counter Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _decrementCount(category.id, item.id, targetCount),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.successGreen
                                        : (isDark
                                            ? AppColors.sageGreenContainer
                                            : const Color(0xFF13362A)),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isDone
                                            ? Icons.check_circle_rounded
                                            : Icons.touch_app_rounded,
                                        size: 18.r,
                                        color: isDone
                                            ? Colors.white
                                            : (isDark ? AppColors.sageGreen : AppColors.accentGold),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        isDone
                                            ? 'تم بحمد الله'
                                            : 'المتبقي: ${QuranMetadata.toArabicDigits(remaining)} من ${QuranMetadata.toArabicDigits(targetCount)}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: isDone
                                              ? Colors.white
                                              : (isDark ? AppColors.sageGreen : AppColors.white),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),

                            // Reset Button
                            if (remaining < targetCount)
                              IconButton(
                                tooltip: 'إعادة العداد',
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  size: 20.r,
                                  color: AppColors.accentGold,
                                ),
                                onPressed: () => _resetCount(category.id, item.id, targetCount),
                              ),

                            // Copy Button
                            IconButton(
                              tooltip: 'نسخ',
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 18.r,
                                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                              ),
                              onPressed: () => _copyDua(item.text),
                            ),

                            // Share Button
                            IconButton(
                              tooltip: 'مشاركة',
                              icon: Icon(
                                Icons.share_outlined,
                                size: 18.r,
                                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                              ),
                              onPressed: () => _shareDua(item.text, category.category),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
