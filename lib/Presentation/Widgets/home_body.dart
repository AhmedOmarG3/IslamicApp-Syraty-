import 'package:flutter/material.dart';
import 'package:siraty/Presentation/Views/azan_view.dart';
import 'package:siraty/Presentation/Views/azkar_view.dart';
import 'package:siraty/Presentation/Views/quran_view.dart';
import 'package:siraty/Presentation/Views/sebha_view.dart';
import 'package:siraty/Presentation/Widgets/custom_card.dart';
import 'package:siraty/Presentation/Widgets/last_read_container.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardsData = [
      {
        'title': 'قرآن',
        'imagePath': 'assets/images/Group.png',
        'color': const Color.fromARGB(255, 140, 204, 151),
        'route': QuranView.routeName,
      },
      {
        'title': 'سبحة',
        'imagePath': 'assets/images/Group 80.png',
        'color': const Color.fromARGB(255, 148, 216, 222),
        'route': SebhaView.routeName,
      },
      {
        'title': 'الاذكار',
        'imagePath': 'assets/images/Group 79.png',
        'color': const Color.fromARGB(255, 148, 216, 222),
        'route': AzkarView.routeName,
      },
      {
        'title': 'الصلاة',
        'imagePath': 'assets/images/praying.png',
        'color': const Color.fromARGB(255, 140, 204, 151),
        'route': AzanView.routeName,
      },
    ];

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: LastReadContainer()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = cardsData[index];
              return CustomCard(
                title: data['title'],
                imagePath: data['imagePath'],
                color: data['color'],
                onTap: () {
                  Navigator.pushNamed(context, data['route']);
                },
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
