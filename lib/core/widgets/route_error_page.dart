import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';

/// Friendly 404 / invalid-route screen shown for unknown URLs or routes
/// opened without their required arguments (e.g. a cold-start deep link).
class RouteErrorPage extends StatelessWidget {
  final String message;

  const RouteErrorPage({super.key, this.message = 'الصفحة غير موجودة'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 56.r,
                color: AppColors.accentGold,
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'تعذّر فتح هذه الصفحة، ربما تم فتح الرابط بشكل غير صحيح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13.sp,
                  color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bgDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
