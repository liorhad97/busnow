import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';
import 'package:busnow/presentation/screens/settings_screen.dart';

/// A widget for the settings button that appears in the top-left corner
class SettingsButton extends ConsumerWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    
    return Material(
      elevation: AppDimensions.elevationSmall,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusCircular),
        onTap: () => _openSettingsScreen(context),
        child: Tooltip(
          message: localizations.translate('settings'),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSmall),
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
              size: AppDimensions.iconSizeMedium,
            ),
          ),
        ),
      ),
    );
  }

  void _openSettingsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
