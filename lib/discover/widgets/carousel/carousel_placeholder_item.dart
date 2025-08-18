import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class CarouselPlaceholderItem extends StatelessWidget {
  const CarouselPlaceholderItem({
    super.key,
    required this.itemWidth,
    required this.onTap,
  });

  final double itemWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark ? colorScheme.surfaceContainerHighest : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isDark ? colorScheme.outline : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv,
              size: itemWidth / 3,
              color: isDark ? colorScheme.onSurfaceVariant : Colors.grey[600],
            ),
            const SizedBox(height: 8.0),
            Text(
              AppLocalizations.of(context)!.noImage,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                        : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
