import 'package:flutter/material.dart';
import 'package:siraty/features/home/presentation/widgets/home_body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        bottom: false,
        child: HomeBody(),
      ),
    );
  }
}
