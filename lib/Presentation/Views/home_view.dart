import 'package:flutter/material.dart';
import 'package:siraty/Presentation/Widgets/home_body.dart';
import 'package:siraty/constant.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const String routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
          height: MediaQuery.of(context).size.height, child: HomeBody()),
    );
  }
}
