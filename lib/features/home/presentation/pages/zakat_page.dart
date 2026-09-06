import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';
import 'package:siraty/features/quran/data/models/quran_metadata.dart';

class ZakatPage extends StatefulWidget {
  const ZakatPage({super.key});

  @override
  State<ZakatPage> createState() => _ZakatPageState();
}

class _ZakatPageState extends State<ZakatPage> {
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();
  final TextEditingController _goldGramPriceController = TextEditingController(text: '3500');

  double get _goldGramPrice => double.tryParse(_goldGramPriceController.text) ?? 3500;
  double get _goldNisabEgp => 85 * _goldGramPrice; // 85 grams of 21k/24k gold

  double get _netZakatWealth {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final gold = double.tryParse(_goldController.text) ?? 0;
    final debts = double.tryParse(_debtsController.text) ?? 0;
    final net = (cash + gold) - debts;
    return net > 0 ? net : 0;
  }

  double get _zakatAmount {
    if (_netZakatWealth >= _goldNisabEgp) {
      return _netZakatWealth * 0.025;
    }
    return 0;
  }

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _debtsController.dispose();
    _goldGramPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final net = _netZakatWealth;
    final zakat = _zakatAmount;
    final reachesNisab = net >= _goldNisabEgp;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(title: 'حاسبة الزكاة'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // Top Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.borderGold,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardHighlight : AppColors.iconBgCircleLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monetization_on_outlined,
                      size: 26.r,
                      color: AppColors.accentGold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'طهّر مالك',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 19.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'احسب زكاة مالك بسهولة وفق نصاب الذهب الشرعي (٨٥ جراماً) — بالجنيه المصري',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Form Inputs Card
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildZakatField(
                    isDark: isDark,
                    label: 'النقد والمدّخرات والحسابات البنكية',
                    controller: _cashController,
                    hint: '٠ ج.م',
                  ),
                  SizedBox(height: 14.h),
                  _buildZakatField(
                    isDark: isDark,
                    label: 'قيمة الذهب والفضة وعروض التجارة',
                    controller: _goldController,
                    hint: '٠ ج.م',
                  ),
                  SizedBox(height: 14.h),
                  _buildZakatField(
                    isDark: isDark,
                    label: 'الديون والمستحقات العاجلة التي عليك (تُخصم)',
                    controller: _debtsController,
                    hint: '٠ ج.م',
                  ),
                  SizedBox(height: 14.h),

                  // Gold Gram Price Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'سعر جرام الذهب عيار ٢١ الحالي:',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100.w,
                        height: 40.h,
                        child: TextField(
                          controller: _goldGramPriceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Result Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: reachesNisab
                            ? AppColors.borderGold
                            : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'صافي المال الزكوي',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                                fontSize: 13.sp,
                              ),
                            ),
                            Text(
                              '${QuranMetadata.toArabicDigits(net.toInt())} ج.م',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'مقدار الزكاة الواجبة (٢.٥٪)',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${QuranMetadata.toArabicDigits(zakat.toInt())} ج.م',
                              style: AppTextStyles.displayLarge.copyWith(
                                color: AppColors.accentGold,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              reachesNisab ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              size: 16.r,
                              color: reachesNisab
                                  ? AppColors.successGreen
                                  : (isDark ? AppColors.textDimmed : AppColors.textDarkMuted),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                reachesNisab
                                    ? 'بلغ النصاب الشرعي (${QuranMetadata.toArabicDigits(_goldNisabEgp.toInt())} ج.م) — تجب فيه الزكاة بعد حولان الحول الهجري كاملاً.'
                                    : 'لم يبلغ النصاب بعد (${QuranMetadata.toArabicDigits(_goldNisabEgp.toInt())} ج.م) — لا تجب الزكاة حتى يبلغ النصاب ويحول عليه الحول.',
                                style: AppTextStyles.caption.copyWith(
                                  color: reachesNisab
                                      ? AppColors.successGreen
                                      : (isDark ? AppColors.textDimmed : AppColors.textDarkMuted),
                                  fontSize: 11.5.sp,
                                  height: 1.4,
                                ),
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
            SizedBox(height: 16.h),

            const OrnamentDivider(),
            SizedBox(height: 12.h),

            // Footnote
            Text(
              'النصاب محسوب على أساس ٨٥ جراماً من الذهب عيار ٢١ وفقاً لجمهور الفقهاء.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildZakatField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            filled: true,
            fillColor: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.accentGold,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
