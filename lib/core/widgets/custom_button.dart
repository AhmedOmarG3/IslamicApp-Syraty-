import 'package:flutter/material.dart';

/// A simple reusable custom button that accepts any widget as its child.
///
/// This widget is used in [HomeSectionsGrid] to wrap the grid tile content.
class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}
