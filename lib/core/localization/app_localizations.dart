import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language enum to represent supported languages
enum Language {
  english(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    isRtl: false,
  ),
  hebrew(
    code: 'he',
    name: 'Hebrew',
    nativeName: 'עברית',
    isRtl: true,
  ),
  arabic(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
  );

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  static Language fromCode(String code) {
    return Language.values.firstWhere(
      (language) => language.code == code,
      orElse: () => Language.english, // Default to English if code not found
    );
  }
}

// Provider for app language
final appLanguageProvider = StateNotifierProvider<AppLanguageNotifier, Language>(
  (ref) => AppLanguageNotifier(),
);

// Notifier for language state
class AppLanguageNotifier extends StateNotifier<Language> {
  AppLanguageNotifier() : super(Language.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      state = Language.fromCode(languageCode);
    }
  }

  Future<void> changeLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', language.code);
    state = language;
  }
}

// AppLocalizations class for handling translations
class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    // Load the language JSON file from the "assets/translations" folder
    String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Getter for checking if the current locale is RTL
  bool get isRtl => Language.fromCode(locale.languageCode).isRtl;
}

// LocalizationsDelegate is a factory for a set of localized resources
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'he', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access to translations
extension TranslateX on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}

// Extension for easy access to RTL check
extension DirectionX on BuildContext {
  bool get isRtl => AppLocalizations.of(this).isRtl;
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;
}