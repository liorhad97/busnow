import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busnow/core/enums/languages.dart';

/// Shared preferences provider for accessing stored preferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// State class to represent the current locale
class LocaleState {
  final Locale locale;
  final Languages language;

  const LocaleState({required this.locale, required this.language});

  // Create copy with updated values
  LocaleState copyWith({Locale? locale, Languages? language}) {
    return LocaleState(
      locale: locale ?? this.locale,
      language: language ?? this.language,
    );
  }

  // Helper to check if current locale is RTL
  bool get isRtl => language.isRtl;
}

/// Notifier class for managing locale state
class LocaleNotifier extends StateNotifier<LocaleState> {
  final Ref ref;
  static const String _localePreferenceKey = 'selected_locale';

  LocaleNotifier(this.ref)
    : super(
        const LocaleState(locale: Locale('en'), language: Languages.english),
      ) {
    _loadSavedLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final savedLocale = prefs.getString(_localePreferenceKey);

      if (savedLocale != null) {
        final language = Languages.fromCode(savedLocale);
        state = state.copyWith(locale: Locale(savedLocale), language: language);
      }
    } catch (e) {
      // Handle error or continue with default locale
      debugPrint('Error loading locale: $e');
    }
  }

  /// Changes the app locale and saves the preference
  Future<void> setLocale(Languages language) async {
    // Only update if it's actually changing
    if (language == state.language) return;

    final newLocale = Locale(language.languageCode);

    // Update state first for immediate UI response
    state = state.copyWith(locale: newLocale, language: language);

    // Then save to preferences
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_localePreferenceKey, language.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
      // Could revert state here if saving fails
    }
  }

  /// Set the app locale to the device locale if supported
  Future<void> useDeviceLocale(BuildContext context) async {
    final deviceLocale = Localizations.localeOf(context);

    if (deviceLocale.languageCode == 'he') {
      await setLocale(Languages.hebrew);
    } else {
      // Default to English for any unsupported language
      await setLocale(Languages.english);
    }
  }
}

/// Main provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((
  ref,
) {
  return LocaleNotifier(ref);
});

/// Helper provider to check if current locale is RTL
final isRtlProvider = Provider<bool>((ref) {
  return ref.watch(localeProvider).isRtl;
});

/// Provider to get the current locale directly
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});

/// Provider to get the current language enum
final currentLanguageProvider = Provider<Languages>((ref) {
  return ref.watch(localeProvider).language;
});
