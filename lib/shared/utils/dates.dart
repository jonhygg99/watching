import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

String formatDate(DateTime date, BuildContext context) {
  final monthNames = AppLocalizations.of(context)!.monthNamesShort.split(',');
  return '${monthNames[date.month - 1].trim()} ${date.day}, ${date.year}';
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
