import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/fonts.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/theme/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.theme,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: kSmallTitleFontSize,
          ),
        ),
        const SizedBox(height: kSpaceBtwTitleWidget),
        Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeProvider);
            return SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.light,
                  icon: const Icon(Icons.light_mode),
                  label: Text(AppLocalizations.of(context)!.light),
                ),
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.dark,
                  icon: const Icon(Icons.dark_mode),
                  label: Text(AppLocalizations.of(context)!.dark),
                ),
                ButtonSegment<AppThemeMode>(
                  value: AppThemeMode.system,
                  icon: const Icon(Icons.phone_android),
                  label: Text(AppLocalizations.of(context)!.system),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<AppThemeMode> selection) {
                ref.read(themeProvider.notifier).setTheme(selection.first);
              },
            );
          },
        ),
      ],
    );
  }
}
