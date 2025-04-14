import 'app_localizations.dart';

/// Hebrew translations
class AppLocalizationsHe implements AppLocalizations {
  // ====================== General ======================
  @override
  String get appTitle => 'באסנאו';

  @override
  String get chooseYourLanguage => 'בחר את השפה שלך';

  @override
  String get save => 'שמור';

  @override
  String get cancel => 'ביטול';

  @override
  String get delete => 'מחיקה';

  @override
  String get confirm => 'אישור';

  @override
  String get search => 'חיפוש';

  @override
  String get loading => 'טוען...';

  @override
  String get error => 'שגיאה';

  // Language settings
  @override
  String get languageSettings => 'הגדרות שפה';

  @override
  String get englishLanguage => 'אנגלית';

  @override
  String get hebrewLanguage => 'עברית';

  @override
  String get systemLanguage => 'ברירת מחדל של המערכת';

  // Bus related
  @override
  String get arriving => 'מגיע';

  @override
  String busArrivalTime(String time) => 'מגיע בשעה $time';

  @override
  String busNumber(String number) => 'קו $number';

  @override
  String busCount(int count) => '$count אוטובוסים';

  @override
  String get busRoutes => 'מסלולי אוטובוס';

  @override
  String get busSchedule => 'לוח זמנים';

  @override
  String get busStops => 'תחנות אוטובוס';

  @override
  String get connectionError => 'שגיאת חיבור. אנא בדוק את חיבור האינטרנט שלך.';

  @override
  String get departed => 'יצא';

  @override
  String get directions => 'הוראות הגעה';

  @override
  String get early => 'מוקדם';

  @override
  String get emptyStateMessage => 'אין מידע להצגה';

  @override
  String get findNearbyStops => 'מצא תחנות קרובות';

  @override
  String get late => 'מאחר';

  @override
  String get locationPermissionDenied =>
      'הרשאת מיקום נדחתה. אנא אפשר שירותי מיקום.';

  @override
  String minutesAbbreviated(int minutes) => '$minutes דק׳';

  @override
  String get minutesAway => 'דקות';

  @override
  String get myLocation => 'המיקום שלי';

  @override
  String get nextBus => 'אוטובוס הבא';

  @override
  String get noResults => 'אין תוצאות';

  @override
  String get noResultsFound => 'לא נמצאו תוצאות';

  @override
  String get ok => 'אישור';

  @override
  String get onTime => 'בזמן';

  @override
  String get recenter => 'מרכז מחדש';

  @override
  String get retry => 'נסה שוב';

  @override
  String get scheduleUnavailable => 'מידע על לוח הזמנים אינו זמין כרגע.';

  @override
  String get zoomIn => 'הגדל';

  @override
  String get zoomOut => 'הקטן';

  @override
  String get arrivalTimes => 'זמני הגעה';

  @override
  String get liveUpdate => 'עדכון בזמן אמת';

  // Bottom sheet messages
  @override
  String get findingBuses => 'מחפש אוטובוסים...';

  @override
  String get noBusesYet => 'אין אוטובוסים עדיין—בדוק שוב בקרוב!';

  @override
  String get tapToRefresh => 'לחץ על רענון כדי לבדוק שוב';
}
