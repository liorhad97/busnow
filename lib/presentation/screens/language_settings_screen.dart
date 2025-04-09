import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/enums/languages.dart';
import 'package:busnow/core/providers/locale_provider.dart';
import 'package:busnow/core/l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(currentLanguageProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: Languages.english,
            label: l10n.englishLanguage,
            currentLanguage: currentLanguage,
          ),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: Languages.hebrew,
            label: l10n.hebrewLanguage,
            currentLanguage: currentLanguage,
          ),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: Languages.arabic,
            label: l10n.arabicLanguage,
            currentLanguage: currentLanguage,
          ),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: Languages.spanish,
            label: l10n.spanishLanguage,
            currentLanguage: currentLanguage,
          ),
          _buildLanguageOption(
            context: context,
            ref: ref,
            language: Languages.russian,
            label: l10n.russianLanguage,
            currentLanguage: currentLanguage,
          ),
          const Divider(),
          _buildSystemOption(context, ref, l10n),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required Languages language,
    required String label,
    required Languages currentLanguage,
  }) {
    final isSelected = currentLanguage == language;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        language.displayName,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(language);
      },
    );
  }

  Widget _buildSystemOption(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return ListTile(
      title: Text(l10n.systemLanguage),
      leading: const Icon(Icons.language),
      onTap: () {
        ref.read(localeProvider.notifier).useDeviceLocale(context);
      },
    );
  }
}
