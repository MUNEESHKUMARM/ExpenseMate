import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Service class for managing persistent app preferences using SharedPreferences.
/// Provides typed getters/setters for budget, theme, and other settings.
class PreferencesService {
  static const String _budgetKey = 'monthly_budget';
  static const String _themeModeKey = 'theme_mode';

  late final SharedPreferences _prefs;

  /// Initialize the service – must be called before any read/write.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Budget ──

  /// Save the monthly budget to persistent storage.
  Future<void> saveBudget(double amount) async {
    await _prefs.setDouble(_budgetKey, amount);
  }

  /// Load the saved monthly budget, or return the default if none was saved.
  double loadBudget() {
    return _prefs.getDouble(_budgetKey) ?? defaultMonthlyBudget;
  }

  // ── Theme Mode ──

  /// Save theme mode: 'amoled' (pure black) or 'light'.
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  /// Load the saved theme mode, defaults to 'amoled'.
  String loadThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'amoled';
  }

  // ── Reset ──

  /// Clear all saved preferences (for data reset).
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
