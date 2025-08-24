import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';
import 'skeleton_utils.dart';

class SkeletonEpisode extends StatelessWidget {
  const SkeletonEpisode({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Episode title and number
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Season and episode number (e.g., T1:E1)
                    SkeletonContainer(height: 20, width: 50, radius: 4),
                    const SizedBox(width: 8),
                    // Episode title
                    SkeletonContainer(height: 20, width: 200, radius: 4),
                  ],
                ),
              ),

              // Watched counter (e.g., 5/10)
              SkeletonContainer(height: 24, width: 50, radius: 12),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          SkeletonContainer(height: 6, width: double.infinity, radius: 3),
          const SizedBox(height: 16),
          // Buttons row
          Row(
            children: [
              // Check All Episodes button
              Expanded(
                child: SkeletonContainer(
                  height: 52,
                  width: double.infinity,
                  radius: 8,
                  margin: const EdgeInsets.only(right: 4),
                ),
              ),

              // Episode Info button
              Expanded(
                child: SkeletonContainer(
                  height: 52,
                  width: double.infinity,
                  radius: 8,
                  margin: const EdgeInsets.only(left: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
