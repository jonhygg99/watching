import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/locale_provider.dart';
import 'package:watching/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final String countryCode;
  final List<String> countryCodes;
  final Map<String, String> countryNames;
  final String? username;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onLoginRegister;
  final VoidCallback onRevokeToken;

  const SettingsPage({
    super.key,
    required this.countryCode,
    required this.countryCodes,
    required this.countryNames,
    required this.username,
    required this.onCountryChanged,
    required this.onLoginRegister,
    required this.onRevokeToken,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.country}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: widget.countryCode,
                  items:
                      widget.countryCodes
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Row(
                                children: [
                                  Text(
                                    String.fromCharCodes(
                                      code.toUpperCase().codeUnits.map(
                                        (c) => 0x1F1E6 - 65 + c,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(widget.countryNames[code] ?? code),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (code) {
                    if (code != null) widget.onCountryChanged(code);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Language Selection
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.language}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Consumer(
                  builder: (context, ref, _) {
                    final currentLocale = ref.watch(localeProvider);
                    return DropdownButton<Locale>(
                      value: currentLocale,
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Row(
                            children: [
                              const Text(
                                '🇬🇧',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.english),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: const Locale('es'),
                          child: Row(
                            children: [
                              const Text(
                                '🇪🇸',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.spanish),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(newLocale);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Theme Toggle
            Text(
              AppLocalizations.of(context)!.theme,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Usuario: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.username ?? 'No conectado'),
              ],
            ),
            const Divider(height: 32),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRevokeToken,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.revokeToken),
            ),
          ],
        ),
      ),
    );
  }
}
