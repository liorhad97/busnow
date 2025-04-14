import 'package:busnow/core/enums/languages.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// TranslationManager provides utilities for working with translations and locale-specific behavior.
///
/// Use this class to:
/// - Access text translations
/// - Format dates, numbers, and other locale-sensitive data
/// - Handle RTL/LTR layout considerations
/// - Manage text directionality
class TranslationManager {
  /// Get the AppLocalizations instance for the given context
  static AppLocalizations? of(BuildContext context) {
    return AppLocalizations.of(context);
  }

  /// Get the text direction (RTL or LTR) based on the current locale
  static TextDirection getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return _isRtlLanguage(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Check if the current locale is an RTL language
  static bool isRtl(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return _isRtlLanguage(locale);
  }

  /// Helper to check if a language code is RTL
  static bool _isRtlLanguage(String languageCode) {
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  /// Get the RTL-aware horizontal padding
  ///
  /// In RTL languages, start/end padding is flipped compared to LTR languages
  static EdgeInsets getDirectionalPadding({
    required BuildContext context,
    double start = 0.0,
    double end = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    final isRtl = TranslationManager.isRtl(context);
    return EdgeInsets.only(
      left: isRtl ? end : start,
      right: isRtl ? start : end,
      top: top,
      bottom: bottom,
    );
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
    // This is a simplified implementation
    // For production apps, use intl package's DateFormat
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'he':
        // 24-hour format is more common in Israel
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      default:
        // 12-hour format with AM/PM for English
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
        // In Hebrew, thousands are separated by commas
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

  /// Get the correct locale code for the given language
  static String getLocaleCode(Languages language) {
    return language.languageCode;
  }

  /// Get a human-readable name for the given language
  static String getLanguageName(Languages language) {
    return language.name;
  }
}
