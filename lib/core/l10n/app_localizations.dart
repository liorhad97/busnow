import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

/// The class responsible for managing localized resources
abstract class AppLocalizations {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('he'), // Hebrew
    Locale('ar'), // Arabic
    Locale('es'), // Spanish
    Locale('ru'), // Russian
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // ====================== General ======================
  String get appTitle;
  String get welcomeMessage;
  String get settingsTitle;
  String get chooseYourLanguage;
  String get save;
  String get cancel;
  String get done;
  String get edit;
  String get delete;
  String get confirm;
  String get search;
  String get share;
  String get back;
  String get details;
  String get close;
  String get continue_;
  String get skip;
  String get next;
  String get finish;
  String get loading;
  String get success;
  String get error;

  /// Language control texts
  String get languageSettings;
  String get englishLanguage;
  String get hebrewLanguage;
  String get arabicLanguage;
  String get spanishLanguage;
  String get russianLanguage;
  String get systemLanguage;
}

/// Delegate class to handle loading the localized resources
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'he', 'ar', 'es', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'he':
      return AppLocalizationsHe();
    case 'ar':
      return AppLocalizationsAr();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'en':
    default:
      return AppLocalizationsEn();
  }
}
