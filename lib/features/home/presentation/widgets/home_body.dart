import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siraty/core/widgets/ornament_divider.dart';
import 'package:siraty/features/home/presentation/widgets/home_daily_ayah.dart';
import 'package:siraty/features/home/presentation/widgets/home_daily_cards.dart';
import 'package:siraty/features/home/presentation/widgets/home_khatma_card.dart';
import 'package:siraty/features/home/presentation/widgets/home_header_banner.dart';
import 'package:siraty/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:siraty/features/home/presentation/widgets/home_sections_grid.dart';
import 'package:siraty/features/home/presentation/widgets/home_today_prayers.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Banner (Greeting, Brand, Location, Next Prayer)
          const HomeHeaderBanner(),
          SizedBox(height: 16.h),

          // 2. Today's Prayers Horizontal Status
          const HomeTodayPrayers(),
          SizedBox(height: 16.h),

          // 3. Daily Routine Dual Cards (Quran + Evening Adhkar)
          const HomeDailyCards(),
          SizedBox(height: 16.h),

          // 4. Quran Khatma Card (ختمة القرآن الكريم)
          const HomeKhatmaCard(),
          SizedBox(height: 16.h),

          // 5. Quick Action Buttons (Qibla, Tasbeeh, Khatma, Names)
          const HomeQuickActions(),
          SizedBox(height: 16.h),

          // 5. Ayah of the Day Card
          const HomeDailyAyah(),
          SizedBox(height: 8.h),

          // 6. Islamic Ornamental Divider
          const OrnamentDivider(),
          SizedBox(height: 16.h),

          // 7. Main Feature Grid Tiles
          const HomeSectionsGrid(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
