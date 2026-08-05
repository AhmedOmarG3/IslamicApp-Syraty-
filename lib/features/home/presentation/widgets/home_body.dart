import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siraty/core/constants/assets.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/widgets/app_card.dart';
import 'package:siraty/features/home/presentation/widgets/last_read_card.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardsData = [
      {
        'title': 'قرآن',
        'imagePath': AppAssets.quranIcon,
        'color': AppColors.cardQuranGreen,
        'route': '/quran',
      },
      {
        'title': 'سبحة',
        'imagePath': AppAssets.tasbeehIcon,
        'color': AppColors.cardSebhaBlue,
        'route': '/tasbeeh',
      },
      {
        'title': 'الاذكار',
        'imagePath': AppAssets.azkarIcon,
        'color': AppColors.cardSebhaBlue,
        'route': '/azkar',
      },
      {
        'title': 'الصلاة',
        'imagePath': AppAssets.prayingIcon,
        'color': AppColors.cardQuranGreen,
        'route': '/prayer',
      },
    ];

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: LastReadCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = cardsData[index];
              return AppCard(
                backgroundColor: data['color'],
                onTap: () {
                  context.push(data['route']);
                },
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        data['title'],
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 40,
                        top: 20,
                      ),
                      child: Image.asset(
                        data['imagePath'],
                        height: 73,
                      ),
                    )
                  ],
                ),
              );
            },
            childCount: cardsData.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
        ),
      ],
    );
  }
}
