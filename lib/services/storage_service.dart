import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyTasbihCount = 'tasbih_count';
  static const String _keyTasbihTarget = 'tasbih_target';
  static const String _keyTasbihTheme = 'tasbih_theme';
  static const String _keyQiblaTheme = 'qibla_theme';
  static const String _keyCalcMethod = 'calc_method';
  static const String _keyMadhab = 'madhab';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Tasbih
  Future<void> saveTasbih(int count, int target, int themeIndex) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyTasbihCount, count);
    await prefs.setInt(_keyTasbihTarget, target);
    await prefs.setInt(_keyTasbihTheme, themeIndex);
  }

  Future<Map<String, int>> loadTasbih() async {
    final prefs = await _prefs;
    return {
      'count': prefs.getInt(_keyTasbihCount) ?? 0,
      'target': prefs.getInt(_keyTasbihTarget) ?? 33,
      'themeIndex': prefs.getInt(_keyTasbihTheme) ?? 0,
    };
  }

  // Qibla Theme
  Future<void> saveQiblaTheme(int themeIndex) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyQiblaTheme, themeIndex);
  }

  Future<int> loadQiblaTheme() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyQiblaTheme) ?? 0;
  }

  // Prayer Settings
  Future<void> savePrayerSettings(int methodIndex, int madhabIndex) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyCalcMethod, methodIndex);
    await prefs.setInt(_keyMadhab, madhabIndex);
  }

  Future<Map<String, int>> loadPrayerSettings() async {
    final prefs = await _prefs;
    return {
      'methodIndex': prefs.getInt(_keyCalcMethod) ?? 0, // default Karachi (0)
      'madhabIndex': prefs.getInt(_keyMadhab) ?? 0, // default Hanafi (0)
    };
  }
}
