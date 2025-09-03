import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class ErrorDialog extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
  });

  static void show(
    BuildContext context, {
    required Object error,
    VoidCallback? onRetry,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          error: error,
          onRetry: onRetry,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.errorLoadingData),
      content: Text(error.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.ok),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry!();
            },
            child: Text(AppLocalizations.of(context)!.retry),
          ),
      ],
    );
  }
}
