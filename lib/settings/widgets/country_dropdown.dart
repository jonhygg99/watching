import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/fonts.dart';
import 'package:watching/shared/constants/measures.dart';

class CountryDropdown extends StatefulWidget {
  final String countryCode;
  final List<String> countryCodes;
  final Map<String, String> countryNames;
  final ValueChanged<String> onCountryChanged;

  const CountryDropdown({
    super.key,
    required this.countryCode,
    required this.countryCodes,
    required this.countryNames,
    required this.onCountryChanged,
  });

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  late String _currentCountryCode = widget.countryCode;

  @override
  void didUpdateWidget(CountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryCode != widget.countryCode) {
      setState(() {
        _currentCountryCode = widget.countryCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${AppLocalizations.of(context)!.country}:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: kSmallTitleFontSize,
          ),
        ),
        const SizedBox(width: kSpaceBtwTitleWidget),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _currentCountryCode,
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
                              style: const TextStyle(fontSize: kEmojiFontSize),
                            ),
                            const SizedBox(width: kSpaceBtwTitleWidget),
                            Expanded(
                              child: Text(
                                widget.countryNames[code] ?? code,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              if (newValue != null && newValue != _currentCountryCode) {
                setState(() {
                  _currentCountryCode = newValue;
                });
                widget.onCountryChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
