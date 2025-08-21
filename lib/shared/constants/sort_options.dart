import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

/// Shared sort options for comments across the app
const Map<String, String> commentSortOptions = {
  'likes': 'Más likes',
  'newest': 'Más recientes',
  'oldest': 'Más antiguos',
  'replies': 'Más respuestas',
  'highest': 'Mejor valorados',
  'lowest': 'Peor valorados',
  'plays': 'Más reproducidos',
  'watched': 'Más vistos',
};

String getTranslatedSortLabel(BuildContext context, String key) {
  final localizations = AppLocalizations.of(context)!;
  switch (key) {
    case 'likes':
      return localizations.sortOptionLikes;
    case 'newest':
      return localizations.sortOptionNewest;
    case 'oldest':
      return localizations.sortOptionOldest;
    case 'replies':
      return localizations.sortOptionReplies;
    case 'highest':
      return localizations.sortOptionHighest;
    case 'lowest':
      return localizations.sortOptionLowest;
    case 'plays':
      return localizations.sortOptionPlays;
    case 'watched':
      return localizations.sortOptionWatched;
    default:
      return '';
  }
}
