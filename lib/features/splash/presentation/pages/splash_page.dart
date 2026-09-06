import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background Islamic Pattern Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF163E31),
                    Color(0xFF0C1B16),
                  ],
                ),
              ),
              child: const CustomPaint(
                painter: IslamicPatternPainter(
                  strokeColor: Color(0x14FFFFFF),
                  cellSize: 54.0,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ),

          // Subtle Radial Glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.2),
                  radius: 0.9,
                  colors: [
                    Colors.transparent,
                    AppColors.bgDark.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Centered Brand Content matching user's image
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold 8-point star
                  Icon(
                    Icons.flare_rounded,
                    size: 36.r,
                    color: AppColors.accentGold,
                  ),
                  SizedBox(height: 16.h),

                  // Brand name "سِيرتي"
                  Text(
                    'سِيرتي',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 44.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textWhite,
                    ),
                  ),

                  // Flourish golden underline
                  Container(
                    width: 70.w,
                    height: 2.h,
                    margin: EdgeInsets.only(top: 4.h, bottom: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Tagline
                  Text(
                    'رفيقك الهادئ في يومك',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
