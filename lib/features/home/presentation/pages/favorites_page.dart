import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/services/favorites_service.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  FavoriteType? _selectedType; // null = All
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await FavoritesService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'المفضلة والمحفوظات',
        trailing: ListenableBuilder(
          listenable: FavoritesService.instance,
          builder: (context, _) {
            final items = FavoritesService.instance.items;
            if (items.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                size: 22.r,
              ),
              tooltip: 'مسح الكل',
              onPressed: () => _confirmClearAll(context),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // 1. Filter Chips Row
          _buildFilterTabs(isDark),

          // 2. Favorites List
          Expanded(
            child: ListenableBuilder(
              listenable: FavoritesService.instance,
              builder: (context, _) {
                final allItems = FavoritesService.instance.items;
                if (_isLoading && allItems.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGold,
                    ),
                  );
                }

                final filtered = _selectedType == null
                    ? allItems
                    : allItems.where((e) => e.type == _selectedType).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildFavoriteCard(context, item, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filters = [
      (null, 'الكل'),
      (FavoriteType.ayah, 'آيات قرآنية'),
      (FavoriteType.hadith, 'أحاديث'),
      (FavoriteType.zekr, 'أذكار'),
    ];

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final (type, label) = filters[index];
          final isSelected = _selectedType == type;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.sageGreen : AppColors.primaryGreen)
                    : (isDark ? AppColors.cardDark : AppColors.cardLight),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12.5.sp,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textMuted : AppColors.textDarkMuted),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteItem item, bool isDark) {
    final (typeBadge, typeColor, typeIcon) = switch (item.type) {
      FavoriteType.ayah => ('آية كريمة', AppColors.accentGold, Icons.menu_book_rounded),
      FavoriteType.hadith => ('حديث شريف', AppColors.sageGreen, Icons.library_books_rounded),
      FavoriteType.zekr => ('ذكر مبارك', const Color(0xFF5A9E87), Icons.auto_stories_rounded),
    };

    final dateFormatted = DateFormat('yyyy/MM/dd').format(item.timestamp);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type Badge, Title, Delete Button
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: typeColor, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 12.r, color: typeColor),
                    SizedBox(width: 4.w),
                    Text(
                      typeBadge,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18.r,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await FavoritesService.instance.removeFavorite(item);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم الحذف من المفضلة'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'تراجع',
                          onPressed: () {
                            FavoritesService.instance.toggleFavorite(item);
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          if (item.subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              item.subtitle,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.sp,
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
              ),
            ),
          ],
          SizedBox(height: 12.h),

          // Content Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              item.content,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15.sp,
                height: 1.8,
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 12.h),

          // Footer: Timestamp & Action Buttons (Copy, Share, Navigate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                QuranMetadata.toArabicDigits(dateFormatted),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18.r,
                      color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'نسخ',
                    onPressed: () {
                      final textToCopy = '${item.content}\n[${item.title}]';
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ النص إلى الحافظة'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 14.w),
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 18.r,
                      color: isDark ? AppColors.accentGold : const Color(0xFF9E7B34),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'مشاركة',
                    onPressed: () {
                      final textToShare = '${item.content}\n\n${item.title}\nمن تطبيق سيرتي';
                      Share.share(textToShare);
                    },
                  ),
                  if (item.type == FavoriteType.ayah) ...[
                    SizedBox(width: 14.w),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Quran reading
                        context.go('/quran');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'قراءة السورة',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.sageGreen : AppColors.primaryGreen,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 10.r,
                              color: isDark ? AppColors.sageGreen : AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : AppColors.cardLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 36.r,
                color: AppColors.accentGold,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              _selectedType == null
                  ? 'لا توجد عناصر محفوظة بالمفضلة'
                  : 'لا توجد عناصر في هذا التصنيف',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'أثناء تصفحك للقرآن والأحاديث والأذكار، اضغط على زر حفظ المفضلة للرجوع إليها هنا في أي وقت.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('مسح جميع المفضلة'),
          content: const Text('هل أنت متأكد من رغبتك في حذف كل العناصر المحفوظة في المفضلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('مسح الكل', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FavoritesService.instance.clearAll();
    }
  }
}

