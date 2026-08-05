import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

class AppLoadingState extends StatelessWidget {
  final double? size;
  final Color? color;

  const AppLoadingState({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorSize = size ?? 40.w;
    return Center(
      child: SizedBox(
        width: indicatorSize,
        height: indicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 3.w,
          color: color ?? AppColors.primaryGreen,
        ),
      ),
    );
  }
}
