import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.color,
      required this.onTap});
  final String title;
  final String imagePath;
  final Color color;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(7),
        elevation: 10,
        color: color,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 40,
                  top: 20,
                ),
                child: Image.asset(
                  height: 73,
                  imagePath,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
