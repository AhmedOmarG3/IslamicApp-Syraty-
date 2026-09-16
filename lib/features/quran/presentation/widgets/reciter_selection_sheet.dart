import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/features/quran/data/services/quran_audio_service.dart';
import 'package:siraty/features/quran/presentation/cubit/quran_audio_cubit.dart';

class ReciterSelectionSheet extends StatefulWidget {
  final bool isDark;
  final ValueChanged<QuranReciter> onReciterSelected;

  const ReciterSelectionSheet({
    super.key,
    required this.isDark,
    required this.onReciterSelected,
  });

  static void show(
    BuildContext context, {
    required bool isDark,
    required ValueChanged<QuranReciter> onReciterSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ReciterSelectionSheet(
        isDark: isDark,
        onReciterSelected: onReciterSelected,
      ),
    );
  }

  @override
  State<ReciterSelectionSheet> createState() => _ReciterSelectionSheetState();
}

class _ReciterSelectionSheetState extends State<ReciterSelectionSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allReciters = QuranAudioCubit.availableReciters;
    final filtered = _searchQuery.trim().isEmpty
        ? allReciters
        : allReciters.where((r) {
            final q = _searchQuery.trim().toLowerCase();
            return r.displayName.toLowerCase().contains(q) ||
                r.name.toLowerCase().contains(q) ||
                r.subname.toLowerCase().contains(q);
          }).toList();

    final selectedReciter =
        context.read<QuranAudioCubit>().state.selectedReciter;

    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.bgDark : AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Drag Handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: widget.isDark
                        ? AppColors.textDimmed
                        : AppColors.textDarkMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Column(
                  children: [
                    Text(
                      'اختيار القارئ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? AppColors.textWhite
                            : AppColors.textDarkPrimary,
                      ),
                    ),
                    Text(
                      '${allReciters.length} قارئاً متاحاً للاستماع',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 11.5.sp,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 44.w), // Balance close button
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.cardDarkElevated
                    : AppColors.iconBgCircleLight,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.borderSubtle
                      : AppColors.borderLight,
                ),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14.sp,
                  color: widget.isDark
                      ? AppColors.textWhite
                      : AppColors.textDarkPrimary,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم القارئ (مثال: السديس، العفاسي)...',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13.sp,
                    color: widget.isDark
                        ? AppColors.textDimmed
                        : AppColors.textDarkMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.accentGold,
                    size: 20.r,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Reciters List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'لم يتم العثور على قارئ بهذا الاسم',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14.sp,
                        color: widget.isDark
                            ? AppColors.textDimmed
                            : AppColors.textDarkMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, idx) {
                      final rec = filtered[idx];
                      final isSelected = rec.id == selectedReciter.id;

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onReciterSelected(rec);
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 11.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (widget.isDark
                                    ? AppColors.sageGreen
                                        .withValues(alpha: 0.18)
                                    : AppColors.primaryGreen
                                        .withValues(alpha: 0.08))
                                : (widget.isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : (widget.isDark
                                      ? AppColors.borderSubtle
                                      : AppColors.borderLight),
                              width: isSelected ? 1.2 : 0.7,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Selected Checkmark Badge or Unselected Radio
                              if (isSelected)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sageGreen,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        size: 14.r,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'مُختار',
                                        style: TextStyle(
                                          fontFamily: 'Amiri',
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Icon(
                                  Icons.radio_button_unchecked_rounded,
                                  size: 18.r,
                                  color: widget.isDark
                                      ? AppColors.textDimmed
                                      : AppColors.textDarkMuted,
                                ),
                              SizedBox(width: 12.w),

                              // Reciter Name & Subname
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      rec.displayName,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.accentGold
                                            : (widget.isDark
                                                ? AppColors.textWhite
                                                : AppColors.textDarkPrimary),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      rec.subname,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 11.5.sp,
                                        color: widget.isDark
                                            ? AppColors.textDimmed
                                            : AppColors.textDarkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),

                              // Leading Avatar Circle
                              Container(
                                width: 38.r,
                                height: 38.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.accentGold
                                          .withValues(alpha: 0.2)
                                      : (widget.isDark
                                          ? AppColors.cardDarkElevated
                                          : AppColors.iconBgCircleLight),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentGold
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Icon(
                                  Icons.record_voice_over_rounded,
                                  size: 18.r,
                                  color: isSelected
                                      ? AppColors.accentGold
                                      : (widget.isDark
                                          ? AppColors.textDimmed
                                          : AppColors.textDarkMuted),
                                ),
                              ),
                            ],
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
