import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  
  // Get the current theme data based on mode
  ThemeData get theme => _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  // Get specific theme based on mode
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  Future<void> _loadTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Try to read as int first (old format)
      final savedThemeInt = _prefs?.getInt(_themeKey);
      if (savedThemeInt != null) {
        // Convert old integer format to ThemeMode
        _themeMode = ThemeMode.values[savedThemeInt];
        // Update to new string format
        await setThemeMode(_themeMode);
        return;
      }

      // Try to read as string (new format)
      final savedThemeStr = _prefs?.getString(_themeKey);
      if (savedThemeStr != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedThemeStr,
          orElse: () => ThemeMode.system,
        );
      } else {
        // Get system theme for first time
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
      // Default to system theme on error
      _themeMode = ThemeMode.system;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    try {
      // Save as string format
      await _prefs?.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
    notifyListeners();
  }

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = isDarkMode(context);
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
} 