import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/localization/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(appLanguageProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'language'.tr(context),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildLanguageOptions(context, ref, currentLanguage),
        ],
      ),
    );
  }

  Widget _buildLanguageOptions(BuildContext context, WidgetRef ref, Language currentLanguage) {
    return Column(
      children: [
        ...Language.values.map((language) => _buildLanguageOption(
              context,
              ref,
              language,
              currentLanguage == language,
            )),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    Language language,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(appLanguageProvider.notifier).changeLanguage(language);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            if (isSelected) const SizedBox(width: 8),
            Expanded(
              child: Text(
                language.nativeName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}