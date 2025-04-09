import 'app_localizations.dart';

/// Russian translations
class AppLocalizationsRu implements AppLocalizations {
  // ====================== General ======================
  @override
  String get appTitle => 'BusNow';

  @override
  String get welcomeMessage => 'Добро пожаловать в BusNow!';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get chooseYourLanguage => 'Выберите ваш язык';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get search => 'Поиск';

  @override
  String get share => 'Поделиться';

  @override
  String get back => 'Назад';

  @override
  String get details => 'Детали';

  @override
  String get close => 'Закрыть';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get finish => 'Завершить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get success => 'Успешно';

  @override
  String get error => 'Ошибка';
  
  @override
  String get detailsMessage => 'Выберите автобусную остановку, чтобы посмотреть расписание';
  
  // ====================== Map Controls ======================
  @override
  String get zoomIn => 'Приблизить';
  
  @override
  String get zoomOut => 'Отдалить';
  
  @override
  String get myLocation => 'Моё местоположение';
  
  // ====================== Error Messages ======================
  @override
  String get loadBusStopsError => 'Ошибка при загрузке автобусных остановок';
  
  @override
  String get loadBusSchedulesError => 'Ошибка при загрузке расписания автобусов';
  
  @override
  String get noStopSelected => 'Не выбрана автобусная остановка';
  
  @override
  String get andMore => 'и другие';

  // Language settings
  @override
  String get languageSettings => 'Настройки языка';

  @override
  String get englishLanguage => 'Английский';

  @override
  String get hebrewLanguage => 'Иврит';
  
  @override
  String get arabicLanguage => 'Арабский';
  
  @override
  String get spanishLanguage => 'Испанский';
  
  @override
  String get russianLanguage => 'Русский';

  @override
  String get systemLanguage => 'Системный по умолчанию';
}
