import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTextStyles.bodyMedium,
        labelStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}
