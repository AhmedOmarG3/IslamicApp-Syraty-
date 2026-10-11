import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siraty/features/quran/presentation/widgets/mushaf_theme_palette.dart';

class MushafSettingsState extends Equatable {
  final MushafThemeMode themeMode;

  const MushafSettingsState({
    this.themeMode = MushafThemeMode.cream,
  });

  @override
  List<Object?> get props => [themeMode];
}

/// Reading preferences for the Mushaf surface (paper theme), persisted to
/// SharedPreferences so the choice survives app restarts.
///
/// There is deliberately no font-size setting: the Madinah Mushaf is rendered
/// with a fixed per-page QCF font, and resizing it would break the printed
/// 15-line page layout.
class MushafSettingsCubit extends Cubit<MushafSettingsState> {
  static const String _themeModeKey = 'mushaf_theme_mode';

  final SharedPreferences _prefs;

  MushafSettingsCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(MushafSettingsState(themeMode: _loadThemeMode(prefs)));

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

  void setThemeMode(MushafThemeMode mode) {
    _prefs.setInt(_themeModeKey, mode.index);
    emit(MushafSettingsState(themeMode: mode));
  }
}
