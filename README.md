# BusNow

A Flutter application for tracking buses and bus stops with real-time information.

## Features

- View bus stops on an interactive map
- Find nearby bus stops based on your location
- Check real-time bus arrival schedules
- Multi-language support

## Localization

The app supports the following languages:

- English (en)
- Hebrew (he)
- Arabic (ar)
- Spanish (es)
- Russian (ru)

### Adding a New Language

To add support for a new language:

1. Update the `Languages` enum in `lib/core/enums/languages.dart`
2. Add the locale to the supported locales list in `lib/core/l10n/app_localizations.dart`
3. Create a new localization file (e.g., `app_localizations_fr.dart` for French)
4. Update the lookup method in `app_localizations.dart` to include the new language

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
