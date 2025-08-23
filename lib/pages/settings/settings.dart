import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/settings/widgets/country_dropdown.dart';
import 'package:watching/pages/settings/widgets/language_dropdown.dart';
import 'package:watching/pages/settings/widgets/revoke_token_button.dart';
import 'package:watching/pages/settings/widgets/theme_selector.dart';
import 'package:watching/pages/settings/widgets/user_info.dart';
import 'package:watching/shared/constants/measures.dart';

class SettingsPage extends HookWidget {
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
  Widget build(BuildContext context) {
    final currentCountryCode = useState(countryCode);

    void handleCountryChanged(String newValue) {
      currentCountryCode.value = newValue;
      onCountryChanged(newValue);
    }

    // Update local state when countryCode changes
    useEffect(() {
      if (currentCountryCode.value != countryCode) {
        currentCountryCode.value = countryCode;
      }
      return null;
    }, [countryCode]);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: Padding(
        padding: kPaddingPhone,
        child: ListView(
          children: [
            CountryDropdown(
              countryCode: currentCountryCode.value,
              countryCodes: countryCodes,
              countryNames: countryNames,
              onCountryChanged: handleCountryChanged,
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            const LanguageDropdown(),
            const SizedBox(height: kSpaceBtwWidgets),
            const ThemeSelector(),
            const SizedBox(height: kSpaceBtwWidgets),
            UserInfo(username: username),
            RevokeTokenButton(onPressed: onRevokeToken),
          ],
        ),
      ),
    );
  }
}
