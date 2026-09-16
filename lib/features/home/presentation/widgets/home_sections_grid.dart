import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/services/favorites_service.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class HomeSectionsGrid extends StatelessWidget {
  const HomeSectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 1. Featured Wide Card: حصن المسلم
        _buildHisnAlMuslimBanner(context: context, isDark: isDark),

        SizedBox(height: 12.h),

        // 2. Dual Services Row: حاسبة الزكاة & المفضلة
        Row(
          children: [
            // حاسبة الزكاة
            Expanded(
              child: _buildZakatCard(context: context, isDark: isDark),
            ),
            SizedBox(width: 12.w),
            // المفضلة
            Expanded(
              child: _buildFavoritesCard(context: context, isDark: isDark),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // 3. Featured Card: أحكام التجويد والوقف
        _buildTajweedBanner(context: context, isDark: isDark),
      ],
    );
  }


  /// Featured Wide Banner for حصن المسلم with real architectural photography background
  Widget _buildHisnAlMuslimBanner({
    required BuildContext context,
    required bool isDark,
  }) {
    final borderColor = AppColors.accentGold.withValues(alpha: isDark ? 0.4 : 0.5);

    return InkWell(
      onTap: () => context.push('/hisn-al-muslim'),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 106.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Real Photography Background: Ancient Andalusian Islamic palace arches
            Positioned.fill(
              child: Image.asset(
                AppAssets.hisnCardBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // 2. Atmospheric Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0B261D).withValues(alpha: 0.90),
                            const Color(0xFF0F3629).withValues(alpha: 0.84),
                            const Color(0xFF071C15).withValues(alpha: 0.93),
                          ]
                        : [
                            const Color(0xFF134233).withValues(alpha: 0.86),
                            const Color(0xFF1C5743).withValues(alpha: 0.78),
                            const Color(0xFF0E3024).withValues(alpha: 0.90),
                          ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
            ),

            // 3. Card Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Icon Medallion
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentGold.withValues(alpha: 0.35),
                          AppColors.accentGold.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.75),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_rounded,
                        color: AppColors.accentGoldLight,
                        size: 26.r,
                      ),
                    ),
                  ),

                  SizedBox(width: 14.w),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'حصن المسلم',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.accentGold.withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '١٣٢ باباً',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGoldLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'أدعية وأذكار جامعة من الكتاب والسنة لكل أحوالك',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5.sp,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Forward Chevron
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13.r,
                      color: AppColors.accentGoldLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zakat Calculator Card with real golden dinar & scale photography
  Widget _buildZakatCard({
    required BuildContext context,
    required bool isDark,
  }) {
    final borderColor = AppColors.accentGold.withValues(alpha: isDark ? 0.38 : 0.48);

    return InkWell(
      onTap: () => context.push('/zakat'),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 122.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Real Photography Background: Gold dinars & antique balance scale
            Positioned.fill(
              child: Image.asset(
                AppAssets.zakatCardBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // 2. Rich Dark Amber Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E170C).withValues(alpha: 0.88),
                            const Color(0xFF130E07).withValues(alpha: 0.94),
                          ]
                        : [
                            const Color(0xFF261C0D).withValues(alpha: 0.84),
                            const Color(0xFF181207).withValues(alpha: 0.90),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 3. Card Content
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Icon + Rate Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentGold.withValues(alpha: 0.22),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.calculate_outlined,
                          size: 20.r,
                          color: AppColors.accentGoldLight,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '2.5%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGoldLight,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حاسبة الزكاة',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'نصاب المال والذهب والفضة',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10.5.sp,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Favorites Card with real green leather Quran book & bookmark photography
  Widget _buildFavoritesCard({
    required BuildContext context,
    required bool isDark,
  }) {
    final borderColor = isDark
        ? const Color(0xFF2C6B57).withValues(alpha: 0.5)
        : const Color(0xFF1E5242).withValues(alpha: 0.4);

    return InkWell(
      onTap: () => context.push('/favorites'),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 122.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Real Photography Background: Handcrafted green leather Quran with gold foil & tassel bookmark
            Positioned.fill(
              child: Image.asset(
                AppAssets.favoritesCardBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // 2. Rich Deep Emerald Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0C241D).withValues(alpha: 0.88),
                            const Color(0xFF061611).withValues(alpha: 0.94),
                          ]
                        : [
                            const Color(0xFF103328).withValues(alpha: 0.84),
                            const Color(0xFF091F18).withValues(alpha: 0.90),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 3. Card Content
            Padding(
              padding: EdgeInsets.all(12.r),
              child: ListenableBuilder(
                listenable: FavoritesService.instance,
                builder: (context, _) {
                  final count = FavoritesService.instance.items.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Icon + Count Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentGold.withValues(alpha: 0.22),
                              border: Border.all(
                                color: AppColors.accentGold.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.bookmark_outline_rounded,
                              size: 20.r,
                              color: AppColors.accentGoldLight,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.accentGold.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              count > 0
                                  ? QuranMetadata.toArabicDigits(count)
                                  : 'جديد',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGoldLight,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المفضلة',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            count > 0
                                ? '${QuranMetadata.toArabicDigits(count)} عناصر محفوظة'
                                : 'آياتك وأحاديثك المحفوظة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5.sp,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Featured Wide Banner for أحكام التجويد والوقف
  Widget _buildTajweedBanner({
    required BuildContext context,
    required bool isDark,
  }) {
    final borderColor = AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.45);

    return InkWell(
      onTap: () => context.push('/tajweed'),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 84.h,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.2),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1B3D31),
                    const Color(0xFF132F25),
                  ]
                : [
                    const Color(0xFF235544),
                    const Color(0xFF1A4235),
                  ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accentGold, width: 1.2),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أحكام التجويد والوقف بالمصحف',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'شرح مبسط للأحكام وعلامات الوقف (مـ، لا، ج، صلى، قلى...) بدون نت',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.sageGreen,
                        fontSize: 11.5.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.accentGold,
                size: 16.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

