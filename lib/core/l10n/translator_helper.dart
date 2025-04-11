import 'package:flutter/material.dart';
import 'package:busnow/core/l10n/app_localizations.dart';

/// Helper class for quickly accessing translations throughout the app
class L10n {
  /// Get all translations for the current context
  static AppLocalizations safe(BuildContext context) {
    return AppLocalizations.safe(context);
  }

  /// Format a date according to the current locale
  static String formatDate(BuildContext context, DateTime date) {
    // This is a simplified implementation
    // For production apps, use intl package's DateFormat
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'he':
        // DD/MM/YYYY for Hebrew
        return '${date.day}/${date.month}/${date.year}';
      default:
        // MM/DD/YYYY for English
        return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Format a time according to the current locale
  static String formatTime(BuildContext context, TimeOfDay time) {
    // Handle different time formats based on locale
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'he':
        // 24-hour format is more common in Israel
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      default:
        // 12-hour format with AM/PM
        final period = time.hour < 12 ? 'AM' : 'PM';
        final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
        return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Format a number according to the current locale
  static String formatNumber(BuildContext context, num number) {
    // This is a simplified implementation
    // For production apps, use intl package's NumberFormat
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'he':
        // Hebrew uses commas as thousands separators
        return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      default:
        // English uses commas as thousands separators
        return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    }
  }

  /// Check if the current locale is RTL
  static bool isRtl(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return ['ar', 'he', 'fa', 'ur'].contains(locale);
  }

  /// Get the text direction for the current locale
  static TextDirection getTextDirection(BuildContext context) {
    return isRtl(context) ? TextDirection.rtl : TextDirection.ltr;
  }
}
