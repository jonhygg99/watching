import 'package:flutter/material.dart';

class InfoItemsRow extends StatelessWidget {
  final List<String> items;

  const InfoItemsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '•',
                style: TextStyle(color: Colors.white70, fontSize: 24),
              ),
            ),
          Text(
            items[i],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 4.0,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
