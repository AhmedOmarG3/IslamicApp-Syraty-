import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_theme_palette.dart';

class MushafSettingsState extends Equatable {
  /// Base ayah font size (surahs with <= 8 verses scale it up 1.15x).
  final double fontSize;
  final MushafThemeMode themeMode;

  const MushafSettingsState({
    this.fontSize = 22.0,
    this.themeMode = MushafThemeMode.cream,
  });

  @override
  List<Object?> get props => [fontSize, themeMode];
}

/// Reading preferences for the Mushaf surface (font size + paper theme),
/// persisted to SharedPreferences so choices survive app restarts.
class MushafSettingsCubit extends Cubit<MushafSettingsState> {
  static const String _fontSizeKey = 'mushaf_font_size';
  static const String _themeModeKey = 'mushaf_theme_mode';

  static const double minFontSize = 17.0;
  static const double maxFontSize = 34.0;

  final SharedPreferences _prefs;

  MushafSettingsCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(
          MushafSettingsState(
            fontSize: _loadFontSize(prefs),
            themeMode: _loadThemeMode(prefs),
          ),
        );

  static double _loadFontSize(SharedPreferences prefs) {
    final saved = prefs.getDouble(_fontSizeKey);
    if (saved == null) return 22.0;
    return saved.clamp(minFontSize, maxFontSize);
  }

  static MushafThemeMode _loadThemeMode(SharedPreferences prefs) {
    final index = prefs.getInt(_themeModeKey);
    if (index == null || index < 0 || index >= MushafThemeMode.values.length) {
      return MushafThemeMode.cream;
    }
    return MushafThemeMode.values[index];
  }

  /// Whether the user ever picked a paper theme (used to decide whether
  /// to follow the app's light/dark mode on first open).
  bool get hasSavedTheme => _prefs.containsKey(_themeModeKey);

  void setFontSize(double size) {
    final clamped = size.clamp(minFontSize, maxFontSize).toDouble();
    _prefs.setDouble(_fontSizeKey, clamped);
    emit(state.copyWith(fontSize: clamped));
  }

  void decreaseFontSize() => setFontSize(state.fontSize - 1.0);

  void increaseFontSize() => setFontSize(state.fontSize + 1.0);

  void setThemeMode(MushafThemeMode mode) {
    _prefs.setInt(_themeModeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }
}

extension _MushafSettingsStateCopyWith on MushafSettingsState {
  MushafSettingsState copyWith({
    double? fontSize,
    MushafThemeMode? themeMode,
  }) {
    return MushafSettingsState(
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
