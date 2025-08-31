import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class ShowDaysLeft extends StatelessWidget {
  const ShowDaysLeft({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final isSingleDigit = days >= 0 && days < 10;
    final isDoubleDigit = days >= 10 && days < 100;

    double getFontSize() {
      if (isSingleDigit) return 40;
      if (isDoubleDigit) return 36;
      return 32; // For 3 digits
    }

    double getContainerWidth() {
      if (isSingleDigit) return 40;
      if (isDoubleDigit) return 60;
      return 80; // For 3 digits
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: getContainerWidth(),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: Text(
              days.toString(),
              style: TextStyle(
                fontSize: getFontSize(),
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            days == 1
                ? AppLocalizations.of(context)!.dayLeftText
                : AppLocalizations.of(context)!.daysLeftText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
