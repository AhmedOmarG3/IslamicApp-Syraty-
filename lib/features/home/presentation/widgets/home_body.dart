import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/features/home/presentation/widgets/daily_inspiration_card.dart';
import 'package:siraty/features/home/presentation/widgets/home_greeting_header.dart';
import 'package:siraty/features/home/presentation/widgets/premium_prayer_card.dart';
import 'package:siraty/features/home/presentation/widgets/quick_services_grid.dart';
import 'package:siraty/features/home/presentation/widgets/quran_resume_banner.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
          const SliverToBoxAdapter(
            child: HomeGreetingHeader(),
          ),
          const SliverToBoxAdapter(
            child: PremiumPrayerCard(),
          ),
          const SliverToBoxAdapter(
            child: QuickServicesGrid(),
          ),
          const SliverToBoxAdapter(
            child: QuranResumeBanner(),
          ),
          const SliverToBoxAdapter(
            child: DailyInspirationCard(),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 30.h),
          ),
        ],
      ),
    );
  }
}
