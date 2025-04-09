import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing supported languages in the app
enum AppLanguage {
  english('en', 'English', true),
  hebrew('he', 'עברית', false),
  arabic('ar', 'العربية', false);

  final String code;
  final String name;
  final bool isLtr; // Direction property (LTR or RTL)

  const AppLanguage(this.code, this.name, this.isLtr);

  /// Factory method to get a language from a locale code
  static AppLanguage fromLocale(String localeCode) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == localeCode,
      orElse: () => AppLanguage.english, // Default to English
    );
  }

  /// Get locale from the language
  Locale get locale => Locale(code);
}

/// Class to manage the app's language and direction settings
class LanguageConfig {
  // Constants for storage
  static const String _languageKey = 'app_language';
  
  // Singleton pattern
  LanguageConfig._();
  static final LanguageConfig _instance = LanguageConfig._();
  static LanguageConfig get instance => _instance;

  // Default language is English (LTR)
  AppLanguage _currentLanguage = AppLanguage.english;
  
  // Stream controller for language changes
  final ValueNotifier<AppLanguage> languageChangeNotifier = ValueNotifier<AppLanguage>(AppLanguage.english);

  /// Get current app language
  AppLanguage get currentLanguage => _currentLanguage;

  /// Get current app direction (LTR or RTL)
  bool get isLtr => _currentLanguage.isLtr;

  /// Get current app locale
  Locale get locale => _currentLanguage.locale;
  
  /// Initialize language settings from storage
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLanguage = prefs.getString(_languageKey);
    
    if (storedLanguage != null) {
      _currentLanguage = AppLanguage.fromLocale(storedLanguage);
      languageChangeNotifier.value = _currentLanguage;
    }
  }

  /// Change the app language
  Future<void> changeLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    
    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
    
    // Notify listeners
    languageChangeNotifier.value = language;
  }
}
