import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'widgets/login_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/login_buttons.dart';
import 'widgets/login_widgets.dart';

/// LoginPage is the entry point for the login flow.
/// Splits UI and logic for maintainability and testability.
class LoginPage extends ConsumerWidget {
  final String? username;
  const LoginPage({super.key, this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use a provider family to pass context safely for navigation/snackbar
    final loginState = ref.watch(loginControllerProvider(context));
    final loginCtrl = ref.read(loginControllerProvider(context).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show user if already known
              UserDisplay(username: username),
              const SizedBox(height: 24),
              // Auth buttons
              LoginButtons(
                loading: loginState.loading,
                onLogin: () => loginCtrl.startAuth(promptLogin: true),
                onSignup: () => loginCtrl.startAuth(signup: true),
              ),
              const SizedBox(height: 32),
              // Show code input if needed
              if (loginState.showCodeInput)
                LoginForm(
                  loading: loginState.loading,
                  error: loginState.error,
                  onSubmit: loginCtrl.submitCode,
                ),
              // Error display (if not already in form)
              ErrorDisplay(error: loginState.error),
            ],
          ),
        ),
      ),
    );
  }
}
