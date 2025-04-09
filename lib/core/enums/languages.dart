/// Enum representing the supported languages in the app
enum Languages {
  english(languageCode: 'en', isRtl: false),
  hebrew(languageCode: 'he', isRtl: true),
  arabic(languageCode: 'ar', isRtl: true),
  spanish(languageCode: 'es', isRtl: false),
  russian(languageCode: 'ru', isRtl: false);

  final String languageCode;
  final bool isRtl;

  const Languages({required this.languageCode, required this.isRtl});

  /// Get the display name of the language
  String get displayName {
    switch (this) {
      case Languages.english:
        return 'English';
      case Languages.hebrew:
        return 'עברית';
      case Languages.arabic:
        return 'العربية';
      case Languages.spanish:
        return 'Español';
      case Languages.russian:
        return 'Русский';
    }
  }

  /// Get language enum from code
  static Languages fromCode(String code) {
    switch (code) {
      case 'he':
        return Languages.hebrew;
      case 'ar':
        return Languages.arabic;
      case 'es':
        return Languages.spanish;
      case 'ru':
        return Languages.russian;
      case 'en':
      default:
        return Languages.english;
    }
  }
}