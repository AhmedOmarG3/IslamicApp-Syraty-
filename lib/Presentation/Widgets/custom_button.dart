import 'package:flutter/material.dart';
import 'package:siraty/Presentation/Views/home_view.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
      onPressed: () {
        Navigator.pushNamed(context, HomeView.routeName);
      },
      child: const Text(
        ' ابدأ',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
