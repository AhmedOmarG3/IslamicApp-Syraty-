import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/tajweed_rule.dart';
import '../../domain/services/tajweed_service.dart';

class TajweedQuickSheet extends StatefulWidget {
  const TajweedQuickSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TajweedQuickSheet(),
    );
  }

  @override
  State<TajweedQuickSheet> createState() => _TajweedQuickSheetState();
}

class _TajweedQuickSheetState extends State<TajweedQuickSheet> {
  List<TajweedCategory> _categories = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0: علامات الوقف بالمصحف, 1: أحكام التجويد السريعة

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await TajweedService.loadTajweedCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final waqfRules = _categories
        .firstWhere((c) => c.id == 'waqf_rules', orElse: () => const TajweedCategory(id: '', title: '', icon: '', description: '', rules: []))
        .rules;

    final otherCategories = _categories.where((c) => c.id != 'waqf_rules').toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 42.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.accentGold,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'دليل علامات وأحكام التلاوة',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                          ),
                        ),
                        Text(
                          'مرجع موثوق وسريع أثناء قراءة المصحف الشريف',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGold,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/tajweed');
                  },
                  child: Text(
                    'عرض الشامل',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13.sp,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // Tab switch: علامات الوقف / أحكام التجويد
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLightElevated,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppColors.accentGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'علامات الوقف بالمصحف',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 0
                                ? const Color(0xFF141C18)
                                : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppColors.accentGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'قواعد التجويد السريعة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedTab == 1
                                ? const Color(0xFF141C18)
                                : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _selectedTab == 0
                    ? ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: waqfRules.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final rule = waqfRules[index];
                          return Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.cardLightElevated,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.accentGold.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: AppColors.accentGold,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        rule.letters,
                                        style: TextStyle(
                                          fontFamily: 'AmiriQuran',
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentGold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        rule.name,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  rule.definition,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 13.5.sp,
                                    color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                if (rule.examples.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.cardDarkElevated : const Color(0xFFFBF6EC),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: AppColors.borderGold.withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'مثال قرآني:',
                                          style: TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 11.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentGold,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '﴿ ${rule.examples.first.word} ﴾',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'AmiriQuran',
                                            fontSize: 14.sp,
                                            height: 1.5,
                                            color: isDark ? AppColors.textWhite : const Color(0xFF141C18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: otherCategories.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final cat = otherCategories[index];
                          return Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.cardLightElevated,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppColors.accentGold,
                                      size: 18.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      cat.title,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  cat.description,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 13.sp,
                                    color: isDark ? AppColors.textMuted : AppColors.textDarkSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Wrap(
                                  spacing: 6.w,
                                  runSpacing: 6.h,
                                  children: cat.rules.map((r) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        r.name,
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accentGold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
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
