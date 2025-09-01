import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/widgets/primary_button.dart';

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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        // Use a fixed height to prevent layout shifts
        layoutBuilder: (currentChild, previousChildren) {
          return SizedBox(
            height: 36, // Match the height of PrimaryButton
            child: Center(
              child: currentChild,
            ),
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: PrimaryButton(
          key: ValueKey<bool>(isExpanded),
          text: isExpanded
              ? AppLocalizations.of(context)!.hideEpisodes
              : AppLocalizations.of(context)!.showMoreEpisodes(episodeCount - 1),
          onPressed: onToggleExpand,
        ),
      ),
    );
  }
}
