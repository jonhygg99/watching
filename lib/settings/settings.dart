import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Row(
              children: [
                const Text(
                  'Tu país:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  String.fromCharCodes(
                    widget.countryCode.toUpperCase().codeUnits.map(
                      (c) => 0x1F1E6 - 65 + c,
                    ),
                  ),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.countryNames[widget.countryCode] ??
                        widget.countryCode,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Cambiar país:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
            const SizedBox(height: 12),
            
            // Theme Toggle
            const Text(
              'Theme:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(themeProvider);
                return SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                    ButtonSegment<AppThemeMode>(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.phone_android),
                      label: Text('System'),
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
              child: const Text('Revocar token Trakt.tv'),
            ),
          ],
        ),
      ),
    );
  }
}
