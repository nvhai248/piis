import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeMode _themeMode;

  ThemeProvider(this._prefs) : _themeMode = ThemeMode.values[_prefs.getInt(_themeKey) ?? ThemeMode.system.index];

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _prefs.setInt(_themeKey, _themeMode.index);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }
} 