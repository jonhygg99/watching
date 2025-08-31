import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';

class EpisodeActionsSkeleton extends StatelessWidget {
  const EpisodeActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
    final highlightColor =
        (isDark ? kSkeletonHighlightColorDark : kSkeletonHighlightColorLight)!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
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
