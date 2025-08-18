import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final String? username;

  const UserInfo({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Usuario: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(username ?? 'No conectado'),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }
}
