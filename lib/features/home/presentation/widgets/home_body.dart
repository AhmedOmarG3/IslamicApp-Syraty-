import 'package:flutter/material.dart';
import 'package:siraty/features/home/presentation/widgets/continue_reading_card.dart';
import 'package:siraty/features/home/presentation/widgets/daily_verse_card.dart';
import 'package:siraty/features/home/presentation/widgets/home_header.dart';
import 'package:siraty/features/home/presentation/widgets/next_prayer_card.dart';
import 'package:siraty/features/home/presentation/widgets/quick_actions_grid.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(child: NextPrayerCard()),
        SliverToBoxAdapter(child: ContinueReadingCard()),
        SliverToBoxAdapter(child: QuickActionsGrid()),
        SliverToBoxAdapter(child: DailyVerseCard()),
        SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
