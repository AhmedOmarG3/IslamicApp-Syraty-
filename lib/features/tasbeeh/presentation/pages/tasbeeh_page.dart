import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/text_styles.dart';
import 'package:siraty/core/widgets/app_header_bar.dart';
import 'package:siraty/core/widgets/islamic_pattern_card.dart';

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage>
    with TickerProviderStateMixin {
  int _counter = 0;
  int _cycles = 0;
  int _selectedZikrIndex = 0;

  // Animation controller for sliding and glowing beads
  late final AnimationController _beadController;
  late Animation<double> _beadAnimation;
  double _currentBeadOffset = 0.0;

  // Animation controller for button tap pulse
  late final AnimationController _buttonPressController;
  late final Animation<double> _buttonScaleAnimation;

  final List<String> _azkar = const [
    'سُبْحَانَ الله',
    'الحَمْدُ لِلَّه',
    'لَا إِلَهَ إِلَّا الله',
    'اللهُ أَكْبَر',
    'أَسْتَغْفِرُ الله',
  ];

  @override
  void initState() {
    super.initState();
    _beadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _beadAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _beadController, curve: Curves.easeOutCubic),
    );

    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _buttonPressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _beadController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  void _onIncrement() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Trigger button spring animation
    _buttonPressController.forward().then((_) {
      if (mounted) {
        _buttonPressController.reverse();
      }
    });

    // Advance bead animation: smooth slide from current offset to next bead
    final startOffset = _currentBeadOffset;
    final targetOffset = startOffset + 1.0;
    _currentBeadOffset = targetOffset;

    _beadAnimation = Tween<double>(begin: startOffset, end: targetOffset).animate(
      CurvedAnimation(parent: _beadController, curve: Curves.easeOutCubic),
    );
    _beadController.forward(from: 0.0);

    setState(() {
      _counter++;
      if (_counter >= 33) {
        _counter = 0;
        _cycles++;
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _reset() {
    if (_counter == 0) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تصفير العداد الحالي (اضغط مطولاً لتصفير الدورات)',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
        ),
        backgroundColor: AppColors.cardDarkElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetAll() {
    if (_counter == 0 && _cycles == 0) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _counter = 0;
      _cycles = 0;
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تصفير العداد وجميع الدورات المكتملة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 13.sp),
        ),
        backgroundColor: AppColors.accentGold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentZikr = _azkar[_selectedZikrIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeaderBar(
        title: 'السبحة',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          // Background subtle Islamic geometric pattern
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                  strokeColor: AppColors.sageGreen.withValues(alpha: isDark ? 0.05 : 0.08),
                  cellSize: 54.0,
                  strokeWidth: 0.9,
                ),
              ),
            ),
          ),

          // Main Interactive Content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // 1. Azkar Filter Chips Bar
                SizedBox(
                  height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _azkar.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedZikrIndex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedZikrIndex = index;
                            _counter = 0;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                                : (isDark ? AppColors.cardDark : AppColors.cardLight),
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                                  : (isDark ? AppColors.borderSubtle : AppColors.borderLight),
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: (isDark ? AppColors.sageGreen : const Color(0xFF1E4538))
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _azkar[index],
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textWhite : AppColors.textDarkPrimary),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Main Selected Zikr Calligraphy
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    currentZikr,
                    key: ValueKey<String>(currentZikr),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ayahText.copyWith(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.sageGreen : AppColors.sageGreenDark,
                      shadows: [
                        Shadow(
                          color: AppColors.sageGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // 3. Curved Metallic Beads Arc
                GestureDetector(
                  onTap: _onIncrement,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 96.h,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _beadController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(double.infinity, 96.h),
                          painter: _AnimatedBeadsArcPainter(
                            progressOffset: _beadAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // 4. Responsive Large Golden Radial Counter Button
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final buttonSize =
                            (constraints.maxHeight * 0.84).clamp(160.0, 230.0.r);

                        return GestureDetector(
                          onTap: _onIncrement,
                          child: AnimatedBuilder(
                            animation: _buttonScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _buttonScaleAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: buttonSize,
                              height: buttonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFF7DE9E),
                                    Color(0xFFD6A258),
                                    Color(0xFFAC772F),
                                    Color(0xFF5A3912),
                                  ],
                                  stops: [0.0, 0.42, 0.80, 1.0],
                                  center: Alignment(-0.15, -0.25),
                                  radius: 0.90,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFF9E4B7)
                                      .withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentGold
                                        .withValues(alpha: 0.35),
                                    blurRadius: 36,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_counter',
                                    style: AppTextStyles.displayLarge.copyWith(
                                      fontSize: (buttonSize * 0.26).sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.bgDark,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    'من ٣٣',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 14.sp,
                                      color: AppColors.bgDark
                                          .withValues(alpha: 0.85),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 5. Bottom Controls: Cycles Counter & Reset Button
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 16.h,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark.withValues(alpha: 0.65)
                        : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Completed cycles on the left (tappable to reset with confirmation)
                      GestureDetector(
                        onTap: () {
                          if (_cycles > 0) {
                            _resetAll();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentGold,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '$_cycles دورة مكتملة',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textWhite : AppColors.textDarkPrimary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Subtle vertical divider
                      Container(
                        width: 1,
                        height: 22.h,
                        color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                      ),

                      // Reset Button on the right (Single tap: reset counter, Long press: reset all)
                      GestureDetector(
                        onTap: _reset,
                        onLongPress: _resetAll,
                        child: Tooltip(
                          message: 'تصفير العداد (اضغط مطولاً لتصفير الدورات)',
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDarkElevated : AppColors.cardLightElevated,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'تصفير',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.textMuted : AppColors.textDarkMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Symmetrically centered beads arc with 3D metallic sphere rendering
/// and an illuminated, noticeably large active bead that glides across the string.
class _AnimatedBeadsArcPainter extends CustomPainter {
  final double progressOffset;

  const _AnimatedBeadsArcPainter({required this.progressOffset});

  @override
  void paint(Canvas canvas, Size size) {
    const totalSlots = 11;
    final centerX = size.width / 2;

    // Radius and geometry of the overarching curve
    final radius = size.width * 0.44;
    // Curve center positioned below so the arc peaks at y = 22
    final curveCenterY = 22.0 + radius;
    // Span angle on each side from peak (-pi/2)
    const spanAngle = 48.0 * (pi / 180.0);

    // 1. Draw the connecting thread cord under the beads
    final threadPath = Path();
    final arcRect = Rect.fromCircle(
      center: Offset(centerX, curveCenterY),
      radius: radius,
    );
    threadPath.addArc(
      arcRect,
      (-pi / 2) - spanAngle,
      spanAngle * 2,
    );

    final threadPaint = Paint()
      ..color = const Color(0xFF6E5325).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(threadPath, threadPaint);

    // 2. Draw beads shifting along the curve
    // In RTL flow, beads advance from right to left
    final slideFract = progressOffset % 1.0;

    for (int k = -1; k <= totalSlots + 1; k++) {
      // Normalized position p along the visible arc from 0.0 (left) to 1.0 (right)
      final p = (k - slideFract) / (totalSlots - 1);

      // Visibility & smooth fade-in / fade-out at the ends
      double opacity = 1.0;
      if (p < 0.0) {
        if (p < -0.15) continue;
        opacity = (p + 0.15) / 0.15;
      } else if (p > 1.0) {
        if (p > 1.15) continue;
        opacity = (1.15 - p) / 0.15;
      }

      opacity = opacity.clamp(0.0, 1.0);

      // Calculate exact angle and 2D coordinates on canvas
      final angle = (-pi / 2) - spanAngle + (p * 2 * spanAngle);
      final x = centerX + radius * cos(angle);
      final y = curveCenterY + radius * sin(angle);

      // 3. Dynamic bead sizing & illumination for the moving / active bead:
      // The bead actively progressing into the lead slot (k=0 / k=1) grows noticeably
      // to 18.0 (more than double the standard 7.5 radius) and radiates intense gold light!
      double beadRadius = 7.5;
      double glowFactor = 0.0;

      if (k == 1) {
        // Bead transitioning from normal into the large illuminated bead
        beadRadius = lerpDouble(7.5, 18.0, slideFract)!;
        glowFactor = slideFract;
      } else if (k == 0) {
        // Previous active bead transitioning back to normal
        beadRadius = lerpDouble(18.0, 7.5, slideFract)!;
        glowFactor = 1.0 - slideFract;
      } else {
        beadRadius = 7.5;
        glowFactor = 0.0;
      }

      final isSpecial = glowFactor > 0.15;

      // A. Drop Shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: (isSpecial ? 0.55 : 0.40) * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSpecial ? 5.0 : 3.0);
      canvas.drawCircle(Offset(x, y + (isSpecial ? 4.0 : 2.5)), beadRadius, shadowPaint);

      // B. Multi-layered Radiant Golden Halo for the moving bead ("منورة")
      if (isSpecial) {
        // Outer soft golden aura
        final outerAuraPaint = Paint()
          ..color = const Color(0xFFFFD56B).withValues(alpha: 0.55 * glowFactor * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
        canvas.drawCircle(Offset(x, y), beadRadius + 7, outerAuraPaint);

        // Inner bright radiant halo
        final innerAuraPaint = Paint()
          ..color = const Color(0xFFFFEA9F).withValues(alpha: 0.75 * glowFactor * opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
        canvas.drawCircle(Offset(x, y), beadRadius + 2.5, innerAuraPaint);
      }

      // C. 3D Metallic Sphere Shader (Glowing 24K Liquid Gold for the active bead)
      final Paint beadPaint = Paint();
      if (isSpecial) {
        beadPaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: opacity),
            const Color(0xFFFFF1C2).withValues(alpha: opacity),
            const Color(0xFFFFD15C).withValues(alpha: opacity),
            const Color(0xFFE59C24).withValues(alpha: opacity),
            const Color(0xFF6B420C).withValues(alpha: opacity),
          ],
          stops: const [0.0, 0.20, 0.55, 0.85, 1.0],
          center: const Alignment(-0.35, -0.35),
          radius: 0.85,
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: beadRadius),
        );
      } else {
        beadPaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFBE4AE).withValues(alpha: opacity),
            const Color(0xFFD4A359).withValues(alpha: opacity),
            const Color(0xFF8F6326).withValues(alpha: opacity),
            const Color(0xFF422B0C).withValues(alpha: opacity),
          ],
          stops: const [0.0, 0.40, 0.78, 1.0],
          center: const Alignment(-0.35, -0.35),
          radius: 0.85,
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: beadRadius),
        );
      }

      canvas.drawCircle(Offset(x, y), beadRadius, beadPaint);

      // D. Fine Rim Accent on the special bead
      if (isSpecial) {
        final rimPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFFFFF3D0).withValues(alpha: 0.75 * glowFactor * opacity);
        canvas.drawCircle(Offset(x, y), beadRadius, rimPaint);
      }

      // E. Specular Highlight / Light Sparkle
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: (isSpecial ? 0.85 : 0.45) * opacity);
      canvas.drawCircle(
        Offset(x - beadRadius * 0.32, y - beadRadius * 0.32),
        beadRadius * (isSpecial ? 0.26 : 0.20),
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBeadsArcPainter oldDelegate) =>
      oldDelegate.progressOffset != progressOffset;
}
