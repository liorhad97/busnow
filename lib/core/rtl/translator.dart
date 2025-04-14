import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/core/l10n/locale_provider.dart';
import 'package:busnow/core/providers/locale_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class for translation-related utilities
class Translator {
  static AppLocalizations? of(BuildContext context) {
    return AppLocalizations.of(context);
  }

  /// Translates a date to a localized string format
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);

    // Format date according to locale conventions
    // This is a simplified example - you might want to use intl package's DateFormat
    switch (locale.languageCode) {
      case 'en':
        // MM/DD/YYYY
        return '${date.month}/${date.day}/${date.year}';
      case 'es':
      case 'fr':
        // DD/MM/YYYY
        return '${date.day}/${date.month}/${date.year}';
      case 'he':
        // DD/MM/YYYY (Hebrew format)
        return '${date.day}/${date.month}/${date.year}';
      default:
        return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Translates a number to a localized string format
  static String formatNumber(BuildContext context, num number) {
    final locale = Localizations.localeOf(context);

    // Format number according to locale conventions
    // This is a simplified example - you might want to use intl package's NumberFormat
    switch (locale.languageCode) {
      case 'en':
        // 1,234.56
        return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      case 'es':
      case 'fr':
        // 1.234,56
        String formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
        return formatted.replaceAll('.', ',');
      case 'he':
        // Hebrew format - similar to English but RTL display
        return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      default:
        return number.toString();
    }
  }

  /// Checks if the current locale reads right-to-left
  static bool isRtl(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
  }
}

/// Provider to get translations for current locale through a WidgetRef
final translationsProvider = Provider.family<AppLocalizations, BuildContext>((
  ref,
  context,
) {
  return AppLocalizations.of(context);
});

/// Provider for date formatting using current locale
final formattedDateProvider = Provider.family<String, DateTimeContext>((
  ref,
  params,
) {
  final locale = ref.watch(currentLocaleProvider);
  final date = params.date;

  // Format date according to locale conventions
  switch (locale.languageCode) {
    case 'en':
      // MM/DD/YYYY
      return '${date.month}/${date.day}/${date.year}';
    case 'es':
    case 'fr':
    case 'he':
      // DD/MM/YYYY
      return '${date.day}/${date.month}/${date.year}';
    default:
      return '${date.month}/${date.day}/${date.year}';
  }
});

/// Provider for number formatting using current locale
final formattedNumberProvider = Provider.family<String, num>((ref, number) {
  final locale = ref.watch(currentLocaleProvider);

  // Format number according to locale conventions
  switch (locale.languageCode) {
    case 'en':
    case 'he':
      // 1,234.56
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    case 'es':
    case 'fr':
      // 1.234,56
      String formatted = number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      return formatted.replaceAll('.', ',');
    default:
      return number.toString();
  }
});

/// Class to combine date and context for the formatted date provider
class DateTimeContext {
  final DateTime date;
  final BuildContext context;

  const DateTimeContext({required this.date, required this.context});
}
