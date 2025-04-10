import 'package:flutter/material.dart';
import 'package:siraty/constant.dart';

class CustomSearchAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onSearchPressed;
  final VoidCallback onClosePressed;


  const CustomSearchAppbar({
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
      title: isSearching
          ? TextField(
              controller: searchController,
              autofocus: true,
             
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            )
          : Text(
              title,
              style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
      actions: [
        isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClosePressed, 
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: onSearchPressed, 
              ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
