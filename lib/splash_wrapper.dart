import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:watching/shared/constants/colors.dart';
import 'main.dart' show MyApp;
import 'login/login_page.dart';
import 'providers/auth_provider.dart';

class SplashWrapper extends ConsumerWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.authenticationError,
                style: TextStyle(color: kErrorColorMessage),
              ),
            ),
          ),
      data: (state) {
        if (state.username == null) {
          // Not authenticated, show login page
          return const LoginPage();
        } else {
          // Authenticated, show main app
          return const MyApp();
        }
      },
    );
  }
}
