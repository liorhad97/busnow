import 'app_localizations.dart';

/// English translations
class AppLocalizationsEn implements AppLocalizations {
  // ====================== General ======================
  @override
  String get appTitle => 'BusNow';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  // Language settings
  @override
  String get languageSettings => 'Language Settings';

  @override
  String get englishLanguage => 'English';

  @override
  String get hebrewLanguage => 'Hebrew';

  @override
  String get systemLanguage => 'System Default';

  @override
  String get arriving => 'Arriving';

  @override
  String busArrivalTime(String time) => 'Arrives at $time';

  @override
  String busNumber(String number) => 'Bus $number';

  @override
  String busCount(int count) => '$count Buses';

  @override
  String get busRoutes => 'Bus Routes';

  @override
  String get busSchedule => 'Bus Schedule';

  @override
  String get busStops => 'Bus Stops';

  @override
  String get connectionError =>
      'Connection error. Please check your internet connection.';

  @override
  String get departed => 'Departed';

  @override
  String get directions => 'Directions';

  @override
  String get early => 'early';

  @override
  String get emptyStateMessage => 'Nothing to display';

  @override
  String get findNearbyStops => 'Find Nearby Stops';

  @override
  String get late => 'late';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Please enable location services.';

  @override
  String minutesAbbreviated(int minutes) => '$minutes min';

  @override
  String get minutesAway => 'minutes away';

  @override
  String get myLocation => 'My Location';

  @override
  String get nextBus => 'Next Bus';

  @override
  String get noResults => 'No Results';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get ok => 'OK';

  @override
  String get onTime => 'On time';

  @override
  String get recenter => 'Recenter';

  @override
  String get retry => 'Retry';

  @override
  String get scheduleUnavailable =>
      'Schedule information is currently unavailable.';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get arrivalTimes => 'Arrival Times';

  @override
  String get liveUpdate => 'Live Update';

  // Bottom sheet messages
  @override
  String get findingBuses => 'Finding buses...';

  @override
  String get noBusesYet => 'No buses yet—check back soon!';

  @override
  String get tapToRefresh => 'Tap refresh to check again';
}
