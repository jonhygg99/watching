import 'package:flutter/material.dart';

/// LoginButtons displays the Trakt login and signup buttons.
class LoginButtons extends StatelessWidget {
  final bool loading;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const LoginButtons({
    super.key,
    required this.loading,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: loading ? null : onLogin,
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Iniciar sesión con Trakt.tv'),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: loading ? null : onSignup,
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Registrarse con Trakt.tv'),
          ),
        ),
      ],
    );
  }
}
