import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';
import 'package:busnow/presentation/widgets/settings/language_selector.dart';

/// Settings screen for the app
/// Contains language and direction configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          children: [
            // Language selector section
            Card(
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSmall),
                child: LanguageSelector(),
              ),
            ),
            
            // Add more settings sections as needed
            const SizedBox(height: AppDimensions.spacingLarge),
          ],
        ),
      ),
    );
  }
}
