import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/providers/locale_provider.dart';
import 'package:watching/shared/constants/fonts.dart';
import 'package:watching/shared/constants/measures.dart';

class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    
    return Row(
      children: [
        Text(
          '${AppLocalizations.of(context)!.language}:'
              .replaceAll(':', ''),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: kSmallTitleFontSize,
          ),
        ),
        const SizedBox(width: kSpaceBtwTitleWidget),
        DropdownButton<Locale>(
          value: currentLocale,
          items: [
            DropdownMenuItem(
              value: const Locale('en'),
              child: Row(
                children: [
                  const Text(
                    '🇬🇧',
                    style: TextStyle(fontSize: kEmojiFontSize),
                  ),
                  const SizedBox(width: kSpaceBtwTitleWidget),
                  const Text('English'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: const Locale('es'),
              child: Row(
                children: [
                  const Text(
                    '🇪🇸',
                    style: TextStyle(fontSize: kEmojiFontSize),
                  ),
                  const SizedBox(width: kSpaceBtwTitleWidget),
                  const Text('Español'),
                ],
              ),
            ),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              ref.read(localeProvider.notifier).setLocale(newLocale);
            }
          },
        ),
      ],
    );
  }
}
