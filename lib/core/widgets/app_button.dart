import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

enum AppButtonType { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final buttonHeight = height ?? AppDimensions.buttonHeight;

    switch (type) {
      case AppButtonType.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: buttonHeight,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: isDisabled ? null : onPressed,
            child: _buildChild(AppColors.primaryGreen),
          ),
        );
      case AppButtonType.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonCream,
              foregroundColor: AppColors.primaryGreen,
              elevation: AppDimensions.elevationFlat,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: isDisabled ? null : onPressed,
            child: _buildChild(AppColors.primaryGreen),
          ),
        );
      case AppButtonType.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              elevation: AppDimensions.elevationFlat,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: isDisabled ? null : onPressed,
            child: _buildChild(AppColors.white),
          ),
        );
    }
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.buttonLabel.copyWith(color: textColor),
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: AppTextStyles.buttonLabel.copyWith(color: textColor),
    );
  }
}
