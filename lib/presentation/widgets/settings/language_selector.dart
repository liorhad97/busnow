import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/config/language_config.dart';
import 'package:busnow/core/providers/app_providers.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';

/// A widget for selecting the app language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final currentLanguage = appSettings.language;
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingSmall,
          ),
          child: Text(
            localizations.translate('language'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        ...AppLanguage.values.map((language) => _buildLanguageOption(
              context,
              language,
              isSelected: language == currentLanguage,
              onLanguageSelected: () {
                ref.read(appSettingsProvider.notifier).changeLanguage(language);
              },
            )),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppLanguage language,
    {required bool isSelected, required VoidCallback onLanguageSelected}
  ) {
    final localizations = AppLocalizations.of(context);
    final directionText = language.isLtr ? localizations.translate('ltr') : localizations.translate('rtl');
    
    return ListTile(
      title: Text(
        language.name,
        textAlign: language.isLtr ? TextAlign.left : TextAlign.right,
      ),
      subtitle: Text(directionText),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: onLanguageSelected,
    );
  }
}
