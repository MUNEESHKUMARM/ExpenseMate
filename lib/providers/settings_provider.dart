import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/database_helper.dart';

/// Provider that manages app settings: theme mode and data reset.
/// Persists settings via SharedPreferences.
class SettingsProvider with ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Theme: 'amoled' (pure black, default) or 'light'
  String _themeMode = 'amoled';
  bool _initialized = false;

  // --- Getters ---

  String get themeMode => _themeMode;
  bool get isAmoled => _themeMode == 'amoled';
  bool get isLight => _themeMode == 'light';
  bool get initialized => _initialized;

  /// Returns the Flutter ThemeMode based on current setting.
  ThemeMode get flutterThemeMode {
    return _themeMode == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  /// Initialize settings from stored preferences.
  Future<void> init() async {
    await _prefs.init();
    _themeMode = _prefs.loadThemeMode();
    _initialized = true;
    notifyListeners();
  }

  /// Toggle between AMOLED dark and Light theme.
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == 'amoled' ? 'light' : 'amoled';
    await _prefs.saveThemeMode(_themeMode);
    notifyListeners();
  }

  /// Set theme mode explicitly.
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.saveThemeMode(mode);
    notifyListeners();
  }

  /// Reset all app data: clear preferences and delete all transactions.
  /// Returns true if successful.
  Future<bool> resetAllData() async {
    try {
      await _dbHelper.deleteAllTransactions();
      await _prefs.clearAll();
      // Re-initialize with defaults
      await _prefs.init();
      _themeMode = 'amoled';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Reset failed: $e');
      return false;
    }
  }
}
