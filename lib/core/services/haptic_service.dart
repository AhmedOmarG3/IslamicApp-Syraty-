import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HapticStrength {
  off,
  light,
  medium,
  heavy,
}

class HapticService {
  static const String _keyStrength = 'settings_haptic_strength';
  static const String _keyCompletion = 'settings_haptic_completion';

  final SharedPreferences _prefs;
  late HapticStrength _strength;
  late bool _completionEnabled;

  HapticService(this._prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedIndex = _prefs.getInt(_keyStrength);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < HapticStrength.values.length) {
      _strength = HapticStrength.values[savedIndex];
    } else {
      _strength = HapticStrength.light;
    }
    _completionEnabled = _prefs.getBool(_keyCompletion) ?? true;
  }

  HapticStrength get strength => _strength;
  bool get completionEnabled => _completionEnabled;

  Future<void> setStrength(HapticStrength newStrength) async {
    _strength = newStrength;
    await _prefs.setInt(_keyStrength, newStrength.index);
    // Give user an immediate preview of the chosen vibration strength
    triggerTap();
  }

  Future<void> setCompletionEnabled(bool enabled) async {
    _completionEnabled = enabled;
    await _prefs.setBool(_keyCompletion, enabled);
    if (enabled) {
      triggerCompletion();
    }
  }

  /// Triggers haptic feedback for regular taps (e.g. bead tap or zekr count decrement)
  void triggerTap() {
    switch (_strength) {
      case HapticStrength.off:
        break;
      case HapticStrength.light:
        HapticFeedback.lightImpact();
        break;
      case HapticStrength.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticStrength.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Triggers distinct feedback when finishing a cycle (e.g. 33 tasbeeh) or finishing a zekr target
  void triggerCompletion() {
    if (!_completionEnabled || _strength == HapticStrength.off) return;

    // A noticeable strong impact for completion
    HapticFeedback.heavyImpact();
  }
}
