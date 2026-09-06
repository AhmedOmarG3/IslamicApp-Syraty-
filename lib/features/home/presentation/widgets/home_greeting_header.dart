import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/spacing.dart';
import 'package:siraty/core/constants/text_styles.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 18.h, 20.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السلام عليكم',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            'رفيقك اليومي للقراءة والذكر والصلاة',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
