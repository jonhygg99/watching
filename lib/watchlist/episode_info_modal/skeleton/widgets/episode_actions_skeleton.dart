import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EpisodeActionsSkeleton extends StatelessWidget {
  const EpisodeActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Comments button placeholder
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(width: 50, height: 18),
          ),

          // Spacer to push the watched button to the right
          const Spacer(),

          // Watch button placeholder
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(width: 50, height: 18),
          ),
        ],
      ),
    );
  }
}
