import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/enums/languages.dart';
import 'package:busnow/core/providers/locale_provider.dart';
import 'package:busnow/core/l10n/app_localizations.dart';

/// A reusable widget that provides a language selection dropdown
class LanguageSelector extends ConsumerWidget {
  final bool useDropdown;
  final bool showIcon;
  
  const LanguageSelector({
    Key? key,
    this.useDropdown = true,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(currentLanguageProvider);
    final l10n = AppLocalizations.of(context);
    
    if (useDropdown) {
      return _buildDropdown(context, ref, currentLanguage, l10n);
    } else {
      return _buildSimpleButton(context, ref, currentLanguage, l10n);
    }
  }
  
  Widget _buildDropdown(BuildContext context, WidgetRef ref, Languages currentLanguage, AppLocalizations l10n) {
    return DropdownButton<Languages>(
      value: currentLanguage,
      icon: showIcon ? const Icon(Icons.language) : null,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Theme.of(context).primaryColor,
      ),
      onChanged: (Languages? language) {
        if (language != null) {
          ref.read(localeProvider.notifier).setLocale(language);
        }
      },
      items: [
        _buildLanguageItem(Languages.english, l10n.englishLanguage),
        _buildLanguageItem(Languages.hebrew, l10n.hebrewLanguage),
        _buildLanguageItem(Languages.arabic, l10n.arabicLanguage),
        _buildLanguageItem(Languages.spanish, l10n.spanishLanguage),
        _buildLanguageItem(Languages.russian, l10n.russianLanguage),
      ],
    );
  }
  
  DropdownMenuItem<Languages> _buildLanguageItem(Languages language, String label) {
    return DropdownMenuItem<Languages>(
      value: language,
      child: Text(
        '$label (${language.displayName})',
        textAlign: language.isRtl ? TextAlign.right : TextAlign.left,
      ),
    );
  }
  
  Widget _buildSimpleButton(BuildContext context, WidgetRef ref, Languages currentLanguage, AppLocalizations l10n) {
    return InkWell(
      onTap: () {
        // Show a simple dialog for language selection
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.chooseYourLanguage),
            children: [
              _buildLanguageOption(context, ref, Languages.english, l10n.englishLanguage),
              _buildLanguageOption(context, ref, Languages.hebrew, l10n.hebrewLanguage),
              _buildLanguageOption(context, ref, Languages.arabic, l10n.arabicLanguage),
              _buildLanguageOption(context, ref, Languages.spanish, l10n.spanishLanguage),
              _buildLanguageOption(context, ref, Languages.russian, l10n.russianLanguage),
              Divider(),
              _buildSystemOption(context, ref, l10n),
            ],
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) Icon(Icons.language, color: Theme.of(context).iconTheme.color),
          if (showIcon) SizedBox(width: 8),
          Text(
            currentLanguage.displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, Languages language, String label) {
    return SimpleDialogOption(
      onPressed: () {
        ref.read(localeProvider.notifier).setLocale(language);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Text(language.displayName, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(width: 8),
          Text('($label)'),
        ],
      ),
    );
  }
  
  Widget _buildSystemOption(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return SimpleDialogOption(
      onPressed: () {
        ref.read(localeProvider.notifier).useDeviceLocale(context);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          const Icon(Icons.settings),
          const SizedBox(width: 8),
          Text(l10n.systemLanguage),
        ],
      ),
    );
  }
}
