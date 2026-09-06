import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'siraty_app_theme_mode';
  final SharedPreferences sharedPreferences;

  ThemeCubit({required this.sharedPreferences})
      : super(_loadInitialTheme(sharedPreferences));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final raw = prefs.getString(_themePrefKey);
    if (raw == 'light') {
      return ThemeMode.light;
    } else if (raw == 'dark') {
      return ThemeMode.dark;
    }
    return ThemeMode.dark; // Default to the iconic Dark theme
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final next = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await sharedPreferences.setString(
      _themePrefKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
    emit(mode);
  }
}
