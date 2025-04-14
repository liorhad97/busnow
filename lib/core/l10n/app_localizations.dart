import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

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
  ];

  /// Gets the localized resources for the given context
  /// Returns null if no AppLocalizations are found in the widget tree
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Gets the localized resources for the given context, with fallback to English
  /// Never returns null - provides English translations if localization is not set up
  static AppLocalizations safe(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
  }

  // General
  String get appTitle;
  String get loading;
  String get error;
  String get retry;
  String get cancel;
  String get confirm;
  String get ok;
  String get save;
  String get delete;
  String get search;
  String get noResults;
  String get noResultsFound;
  String get emptyStateMessage;

  // Language settings
  String get languageSettings;
  String get chooseYourLanguage;
  String get englishLanguage;
  String get hebrewLanguage;
  String get systemLanguage;

  // Bus related
  String get busStops;
  String get busRoutes;
  String get busSchedule;
  String get nextBus;
  String get arriving;
  String get departed;
  String get minutesAway;
  String get early;
  String get onTime;
  String get late;
  String minutesAbbreviated(int minutes);
  String busNumber(String number);
  String busArrivalTime(String time);
  String busCount(int count);

  // Map related
  String get myLocation;
  String get findNearbyStops;
  String get directions;
  String get zoomIn;
  String get zoomOut;
  String get recenter;

  // Errors
  String get connectionError;
  String get locationPermissionDenied;
  String get scheduleUnavailable;

  String get arrivalTimes;
  String get liveUpdate;

  // Bottom sheet messages
  String get findingBuses;
  String get noBusesYet;
  String get tapToRefresh;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'he'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_createLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  AppLocalizations _createLocalization(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'he':
        return AppLocalizationsHe();
      default:
        return AppLocalizationsEn();
    }
  }
}
