import 'package:flutter/material.dart';
import 'package:siraty/core/constants/dimensions.dart';
import 'package:siraty/core/constants/text_styles.dart';

class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onSearchPressed;
  final VoidCallback onClosePressed;

  const CustomSearchAppBar({
    super.key,
    required this.title,
    required this.hintText,
    required this.searchController,
    required this.isSearching,
    required this.onSearchPressed,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching ? _searchField() : _title(),
      actions: [
        IconButton(
          tooltip: isSearching ? 'إغلاق البحث' : 'بحث',
          onPressed: isSearching ? onClosePressed : onSearchPressed,
          icon: Icon(isSearching ? Icons.close_rounded : Icons.search_rounded),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.start,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration.collapsed(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _title() {
    return Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}
