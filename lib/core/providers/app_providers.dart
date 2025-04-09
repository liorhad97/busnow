import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/config/language_config.dart';

/// State class for app settings
class AppSettingsState {
  final AppLanguage language;
  final bool isLtr;

  AppSettingsState({
    required this.language,
    required this.isLtr,
  });

  // Create a copy with some fields replaced
  AppSettingsState copyWith({
    AppLanguage? language,
    bool? isLtr,
  }) {
    return AppSettingsState(
      language: language ?? this.language,
      isLtr: isLtr ?? this.isLtr,
    );
  }
}

/// Provider for app settings
class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  final LanguageConfig _languageConfig = LanguageConfig.instance;

  AppSettingsNotifier()
      : super(AppSettingsState(
          language: LanguageConfig.instance.currentLanguage,
          isLtr: LanguageConfig.instance.isLtr,
        )) {
    // Initialize language from stored preferences
    _initializeLanguage();

    // Listen for language changes
    _languageConfig.languageChangeNotifier.addListener(_onLanguageChanged);
  }

  Future<void> _initializeLanguage() async {
    await _languageConfig.initializeLanguage();
    state = state.copyWith(
      language: _languageConfig.currentLanguage,
      isLtr: _languageConfig.isLtr,
    );
  }

  void _onLanguageChanged() {
    state = state.copyWith(
      language: _languageConfig.currentLanguage,
      isLtr: _languageConfig.isLtr,
    );
  }

  // Change language method
  Future<void> changeLanguage(AppLanguage language) async {
    await _languageConfig.changeLanguage(language);
  }

  @override
  void dispose() {
    _languageConfig.languageChangeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }
}

// Provider for app settings
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier();
});
