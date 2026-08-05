import 'package:flutter/material.dart';
import 'package:siraty/core/constants/colors.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final String hintText;
  final TextEditingController? searchController;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onClosePressed;
  final List<Widget>? actions;
  final Widget? leading;

  const AppAppBar({
    super.key,
    required this.title,
    this.isSearching = false,
    this.hintText = 'ابحث...',
    this.searchController,
    this.onSearchPressed,
    this.onClosePressed,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: isSearching && searchController != null
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: AppTextStyles.bodyLarge,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            )
          : Text(
              title,
              style: AppTextStyles.appBarTitle,
            ),
      centerTitle: true,
      actions: actions ??
          (onSearchPressed != null
              ? [
                  isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.primaryGreen),
                          onPressed: onClosePressed,
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, color: AppColors.primaryGreen),
                          onPressed: onSearchPressed,
                        ),
                ]
              : null),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}
