import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/service_locator.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/app_header_bar.dart';
import '../../data/datasource/city_database_data_source.dart';
import '../cubit/azan_cubit.dart';
import '../cubit/azan_state.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  final CityDatabaseDataSource _cityDatabase = getIt<CityDatabaseDataSource>();

  List<CityRecord> _cities = [];
  bool _isLoading = true;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);
    final list = await _cityDatabase.getAllCities();
    if (mounted) {
      setState(() {
        _cities = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    final results = await _cityDatabase.searchCities(query);
    if (mounted) {
      setState(() => _cities = results);
    }
  }

  Future<void> _onDetectGpsPressed() async {
    setState(() => _isDetecting = true);
    final cubit = context.read<AzanCubit>();
    final success = await cubit.autoDetectLocation();
    if (!mounted) return;
    setState(() => _isDetecting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد موقعك بنجاح'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      if (context.canPop()) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديد الموقع، يرجى تفعيل الـ GPS ومنح الإذن أو اختيار مدينتك يدويًا'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'تحديد موقع الصلاة',
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          // Auto GPS card
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: InkWell(
              onTap: _isDetecting ? null : _onDetectGpsPressed,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : const Color(0xFFF2ECE0),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? AppColors.borderGold : AppColors.accentGold,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardHighlight
                            : AppColors.accentGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: _isDetecting
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentGold,
                              ),
                            )
                          : Icon(
                              Icons.my_location_rounded,
                              color: AppColors.accentGold,
                              size: 22.r,
                            ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تحديد الموقع تلقائيًا (GPS)',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'ضبط التوقيت بدقة حسب إحداثياتك الحالية',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                              fontSize: 11.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                      size: 16.r,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم المدينة أو الدولة...',
                hintStyle: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.accentGold),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
                ),
              ),
            ),
          ),

          // Cities List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accentGold),
                  )
                : _cities.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد نتائج مطابقة',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.textDimmed : AppColors.textDarkMuted,
                          ),
                        ),
                      )
                    : BlocBuilder<AzanCubit, AzanState>(
                        builder: (context, state) {
                          String? currentCity;
                          if (state is AzanLoadedState) {
                            currentCity = state.derivedToday.location.cityName;
                          }

                          return ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            itemCount: _cities.length,
                            separatorBuilder: (_, __) => SizedBox(height: 6.h),
                            itemBuilder: (context, index) {
                              final city = _cities[index];
                              final isSelected = currentCity == city.cityName;

                              return InkWell(
                                onTap: () {
                                  context.read<AzanCubit>().changeLocation(
                                        city.toPrayerLocation(),
                                      );
                                  context.pop();
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.cardHighlight
                                            : const Color(0xFFF2ECE0))
                                        : (isDark ? AppColors.cardDark : AppColors.cardLight),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentGold
                                          : (isDark
                                              ? AppColors.borderSubtle
                                              : AppColors.borderLight),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_outlined,
                                        color: isSelected
                                            ? AppColors.accentGold
                                            : (isDark
                                                ? AppColors.sageGreen
                                                : const Color(0xFF4A7D6E)),
                                        size: 20.r,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              city.cityName,
                                              style: AppTextStyles.titleSmall.copyWith(
                                                color: isDark
                                                    ? AppColors.textWhite
                                                    : AppColors.textDarkPrimary,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Text(
                                              city.countryName,
                                              style: AppTextStyles.caption.copyWith(
                                                color: isDark
                                                    ? AppColors.textDimmed
                                                    : AppColors.textDarkMuted,
                                                fontSize: 11.5.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.accentGold,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
