import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';
import 'package:siraty/Presentation/Widgets/custom_button.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  static String routeName = 'SplashView';
  @override
  State<SplashView> createState() => _CreativeSplashViewState();
}

class _CreativeSplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F3930), Color(0xFF2C7865)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        width: double.infinity,
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الهلال
              Image.asset('assets/images/Group 35.png'),
              const SizedBox(height: 20),
              // اسم التطبيق
              const Text(
                appName,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 10),
              // الجملة المحفزة
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'رحلة إيمانية في قلب القرآن الكريم\nاستمع، اقرأ، وتدبر في كل وقت ومكان',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // الزر
              const CustomButton(),
            ],
          ),
        ),
      ),
    );
  }
}
