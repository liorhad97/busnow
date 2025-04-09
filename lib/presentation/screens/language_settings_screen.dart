import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/enums/languages.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/core/providers/locale_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(currentLanguageProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        // Ensure appbar actions are on the correct side based on RTL/LTR
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseYourLanguage,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Language selection cards
            _buildLanguageCard(
              context,
              ref,
              Languages.english,
              l10n.englishLanguage,
              isSelected: currentLanguage == Languages.english,
            ),

            const SizedBox(height: 12),

            _buildLanguageCard(
              context,
              ref,
              Languages.hebrew,
              l10n.hebrewLanguage,
              isSelected: currentLanguage == Languages.hebrew,
            ),

            const SizedBox(height: 24),

            // System language option
            OutlinedButton.icon(
              onPressed: () {
                ref.read(localeProvider.notifier).useDeviceLocale(context);
              },
              icon: const Icon(Icons.smartphone),
              label: Text(l10n.systemLanguage),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    Languages language,
    String displayName, {
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(language);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Flag or language icon could be added here
              Expanded(
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: language.isRtl ? TextAlign.right : TextAlign.left,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
