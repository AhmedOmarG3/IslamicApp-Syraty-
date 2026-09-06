import 'package:flutter/material.dart';
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
              textAlign: TextAlign.start,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMedium,
              ),
            )
          : Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      actions: actions ?? _searchActions(),
    );
  }

  List<Widget>? _searchActions() {
    if (onSearchPressed == null) return null;
    return [
      IconButton(
        tooltip: isSearching ? 'إغلاق البحث' : 'بحث',
        onPressed: isSearching ? onClosePressed : onSearchPressed,
        icon: Icon(isSearching ? Icons.close_rounded : Icons.search_rounded),
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}
