import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/presentation/widgets/settings/language_selector.dart';

/// Settings screen for the app
/// Contains language and direction configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          children: const [
            // Language selector section
            Card(
              margin: EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingSmall),
                child: LanguageSelector(),
              ),
            ),
            
            // Add more settings sections as needed
            SizedBox(height: AppDimensions.spacingLarge),
          ],
        ),
      ),
    );
  }
}
