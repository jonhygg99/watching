import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/sort_options.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.filters,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items:
              sortKeys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(getTranslatedSortLabel(context, key)),
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
