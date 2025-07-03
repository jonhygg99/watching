import 'package:flutter/material.dart';

/// A skeleton loading widget for watchlist items
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder:
          (context, index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
    );
  }
}
