import 'package:flutter/material.dart';

class VideoFilterChips extends StatelessWidget {
  final Map<String, bool> selectedTypes;
  final ValueChanged<String> onTypeToggled;

  const VideoFilterChips({
    super.key,
    required this.selectedTypes,
    required this.onTypeToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            selectedTypes.entries.map((entry) {
              final type = entry.key;
              final isSelected = entry.value;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => onTypeToggled(type),
                  showCheckmark: false,
                  backgroundColor:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
