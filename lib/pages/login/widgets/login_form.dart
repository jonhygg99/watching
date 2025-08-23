import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';

/// LoginForm displays the code input and handles submission.
class LoginForm extends ConsumerWidget {
  final bool loading;
  final String? error;
  final void Function(String) onSubmit;

  const LoginForm({
    super.key,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a local controller so it resets on rebuild
    final codeController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: codeController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.authCodeLabel,
            errorText: error,
          ),
          enabled: !loading,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed:
                loading ? null : () => onSubmit(codeController.text.trim()),
            child:
                loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(AppLocalizations.of(context)!.submitCodeButton),
          ),
        ),
      ],
    );
  }
}
