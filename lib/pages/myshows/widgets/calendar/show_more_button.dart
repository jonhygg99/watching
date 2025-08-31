import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class ShowMoreButton extends StatelessWidget {
  final bool isExpanded;
  final int episodeCount;
  final VoidCallback onToggleExpand;

  const ShowMoreButton({
    super.key,
    required this.isExpanded,
    required this.episodeCount,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: onToggleExpand,
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all<Size>(
            const Size(double.infinity, 36),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            return Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.12);
          }),
          elevation: WidgetStateProperty.all<double>(0),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (
            Widget child,
            Animation<double> animation,
          ) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                child: child,
              ),
            );
          },
          child: Center(
            child: Text(
              key: ValueKey<bool>(isExpanded),
              isExpanded
                  ? AppLocalizations.of(context)!.hideEpisodes
                  : AppLocalizations.of(context)!
                      .showMoreEpisodes(episodeCount - 1),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
