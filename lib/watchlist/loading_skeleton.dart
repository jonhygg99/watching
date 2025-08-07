import 'package:flutter/material.dart';

/// A skeleton loading widget for watchlist items
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: 5,
      shrinkWrap: true,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
    );
  }
}
