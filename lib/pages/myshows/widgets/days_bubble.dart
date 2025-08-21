import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class DaysBubble extends StatelessWidget {
  const DaysBubble({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.only(left: 8, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A), // Purple color
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9C27B0), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            days.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.daysLeftText,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
