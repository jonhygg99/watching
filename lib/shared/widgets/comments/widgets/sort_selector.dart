import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class CommentsSortSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<String> sortKeys;

  const CommentsSortSelector({
    super.key,
    required this.value,
    required this.sortKeys,
    required this.onChanged,
  });

  String _getTranslatedSortLabel(BuildContext context, String key) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.filters,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: sortKeys
              .map(
                (key) => DropdownMenuItem(
                  value: key,
                  child: Text(_getTranslatedSortLabel(context, key)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          isExpanded: false,
        ),
      ],
    );
  }
}
