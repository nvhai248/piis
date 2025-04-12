import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  final SharedPreferences _prefs;
  
  Locale _locale;

  LanguageProvider(this._prefs) : _locale = Locale(_prefs.getString(_languageKey) ?? 'en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'vi'].contains(locale.languageCode)) return;
    
    _locale = locale;
    _prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  String get currentLanguage => _locale.languageCode == 'en' ? 'English' : 'Tiếng Việt';
} 