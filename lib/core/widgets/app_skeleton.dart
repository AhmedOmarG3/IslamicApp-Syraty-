import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/constants/colors.dart';

/// Core Shimmer effect that sweeps across child widgets to create a skeleton loading feel
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF142923) : const Color(0xFFEDE5D8);
    final highlightColor =
        isDark ? const Color(0xFF22443A) : const Color(0xFFFFFDF9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Generic Skeleton Shape with rounded corners
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        color ?? (isDark ? const Color(0xFF18332C) : const Color(0xFFE5DEC9));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(8.r)),
      ),
    );
  }
}

/// Skeleton for Surah list matching Screenshot 2 layout
class SurahListSkeleton extends StatelessWidget {
  final int itemCount;

  const SurahListSkeleton({
    super.key,
    this.itemCount = 9,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.8,
          color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
            child: Row(
              children: [
                // Star badge rosette placeholder
                SkeletonBox(
                  width: 38.r,
                  height: 38.r,
                  shape: BoxShape.circle,
                ),
                SizedBox(width: 14.w),

                // Surah info placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surah name
                    SkeletonBox(
                      width: 85.w + (index % 4) * 15.w,
                      height: 18.h,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    SizedBox(height: 6.h),
                    // Ayahs count & Makki/Madani
                    SkeletonBox(
                      width: 65.w,
                      height: 12.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton for Surah reading view giving immediate page feel
class SurahReadingSkeleton extends StatelessWidget {
  const SurahReadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Surah Header Plaque Placeholder
              SkeletonBox(
                width: double.infinity,
                height: 52.h,
                borderRadius: BorderRadius.circular(14.r),
              ),
              SizedBox(height: 16.h),

              // Bismillah Placeholder
              Center(
                child: SkeletonBox(
                  width: 140.w,
                  height: 24.h,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Flowing Verse Lines (varied widths for authentic text look)
              ...List.generate(9, (i) {
                final widths = [
                  1.0,
                  0.95,
                  0.98,
                  0.88,
                  1.0,
                  0.92,
                  0.96,
                  0.84,
                  0.70
                ];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: SkeletonBox(
                    width: double.infinity * widths[i % widths.length],
                    height: 16.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for Quran Audio Player Page
class AudioPlayerSkeleton extends StatelessWidget {
  const AudioPlayerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        child: Column(
          children: [
            // Top Cover Card Skeleton
            SkeletonBox(
              width: double.infinity,
              height: 190.h,
              borderRadius: BorderRadius.circular(26.r),
            ),
            SizedBox(height: 18.h),

            // Live Ayah Card Skeleton
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color:
                      isDark ? AppColors.borderSubtle : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  SkeletonBox(width: 45.w, height: 14.h),
                  SizedBox(height: 14.h),
                  SkeletonBox(width: double.infinity, height: 22.h),
                  SizedBox(height: 8.h),
                  SkeletonBox(width: 200.w, height: 22.h),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Progress Slider Bar
            SkeletonBox(
              width: double.infinity,
              height: 6.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
            SizedBox(height: 24.h),

            // Controls Row (Forward, Play Circle, Rewind)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonBox(width: 32.r, height: 32.r, shape: BoxShape.circle),
                SizedBox(width: 36.w),
                SkeletonBox(width: 68.r, height: 68.r, shape: BoxShape.circle),
                SizedBox(width: 36.w),
                SkeletonBox(width: 32.r, height: 32.r, shape: BoxShape.circle),
              ],
            ),
            SizedBox(height: 32.h),

            // Reciter Pills Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SkeletonBox(
                  width: 120.w,
                  height: 44.h,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                SizedBox(width: 10.w),
                SkeletonBox(
                  width: 120.w,
                  height: 44.h,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for Azkar and Hisn Al-Muslim pages
class AzkarListSkeleton extends StatelessWidget {
  const AzkarListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? AppColors.borderSubtle : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(
                        width: 32.r, height: 32.r, shape: BoxShape.circle),
                    SkeletonBox(
                        width: 60.w,
                        height: 20.h,
                        borderRadius: BorderRadius.circular(12.r)),
                  ],
                ),
                SizedBox(height: 14.h),
                SkeletonBox(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: double.infinity, height: 16.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 160.w, height: 16.h),
                SizedBox(height: 16.h),
                SkeletonBox(
                  width: double.infinity,
                  height: 44.h,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
