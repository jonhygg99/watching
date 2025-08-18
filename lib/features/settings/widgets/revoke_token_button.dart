import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class RevokeTokenButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RevokeTokenButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      ),
      child: Text(AppLocalizations.of(context)!.revokeToken),
    );
  }
}
