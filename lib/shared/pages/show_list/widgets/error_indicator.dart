import 'package:flutter/material.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.padding = const EdgeInsets.all(8),
  });

  final String errorMessage;
  final VoidCallback onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: padding,
        color: Colors.red[50],
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: kErrorColorMessage),
            const SizedBox(width: kSpaceBtwTitleWidget),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(color: kErrorColorMessage),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
