/// Enum representing the supported languages in the app
enum Languages {
  english(languageCode: 'en', isRtl: false),
  hebrew(languageCode: 'he', isRtl: true);

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
    }
  }

  /// Get language enum from code
  static Languages fromCode(String code) {
    switch (code) {
      case 'he':
        return Languages.hebrew;
      case 'en':
      default:
        return Languages.english;
    }
  }
}
