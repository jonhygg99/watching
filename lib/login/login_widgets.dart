import 'package:flutter/material.dart';

/// Displays the current user if logged in.
class UserDisplay extends StatelessWidget {
  final String? username;
  const UserDisplay({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    if (username == null) return const SizedBox();
    return Column(
      children: [
        const Icon(Icons.person, size: 32, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          'Hola, $username',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Displays error messages in a styled way.
class ErrorDisplay extends StatelessWidget {
  final String? error;
  const ErrorDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        error!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
