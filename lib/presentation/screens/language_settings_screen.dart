import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/enums/languages.dart';
import 'package:busnow/core/l10n/locale_provider.dart';
import 'package:busnow/core/rtl/translator_helper.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localeProvider).language;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)?.languageSettings ?? 'Language Settings'),
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
              L10n.of(context)?.chooseYourLanguage ?? 'Choose Your Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Language selection cards
            _buildLanguageCard(
              context,
              ref,
              Languages.english,
              L10n.of(context)?.englishLanguage ?? 'English',
              isSelected: currentLanguage == Languages.english,
            ),

            const SizedBox(height: 12),

            _buildLanguageCard(
              context,
              ref,
              Languages.hebrew,
              L10n.of(context)?.hebrewLanguage ?? 'Hebrew',
              isSelected: currentLanguage == Languages.hebrew,
            ),

            const SizedBox(height: 24),

            // System language option
            OutlinedButton.icon(
              onPressed: () {
                ref.read(localeProvider.notifier).useDeviceLocale(context);
              },
              icon: const Icon(Icons.smartphone),
              label: Text(
                L10n.of(context)?.systemLanguage ?? 'System Language',
              ),
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
              // Language name with larger, bold text
              Expanded(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),

              // Checkmark for selected language
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
