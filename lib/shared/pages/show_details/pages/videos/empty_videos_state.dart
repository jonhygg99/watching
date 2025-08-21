import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class EmptyVideosState extends StatelessWidget {
  const EmptyVideosState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 64,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noVideosMatchingFilters,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
