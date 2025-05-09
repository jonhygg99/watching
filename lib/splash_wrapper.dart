import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart' show MyApp;
import 'login/login_page.dart';
import 'providers/auth_provider.dart';

/// SplashWrapper now uses Riverpod for authentication state.
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
              child: Text('Error: $err', style: TextStyle(color: Colors.red)),
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
