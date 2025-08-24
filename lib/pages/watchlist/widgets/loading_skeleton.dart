import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';

/// A skeleton loading widget for watchlist items with shimmer effect
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
    final highlightColor =
        (isDark ? kSkeletonHighlightColorDark : kSkeletonHighlightColorLight)!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        itemCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => _buildSkeletonItem(context),
      ),
    );
  }

  Widget _buildSkeletonItem(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      elevation: 0,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster placeholder (matches ShowCard dimensions)
          Container(
            width: 110,
            height: 165,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Content (matches WatchProgressInfo layout)
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show title (titleMedium with bold)
                Container(
                  height:
                      textTheme.titleMedium?.fontSize != null
                          ? textTheme.titleMedium!.fontSize! *
                              1.4 // Account for line height
                          : 24,
                  width: 200,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(bottom: 8),
                ),

                // Episode info (T1E1 - Episode Title) - bodyMedium style
                Container(
                  height:
                      textTheme.bodyMedium?.fontSize != null
                          ? textTheme.bodyMedium!.fontSize! *
                              1.4 // Account for line height
                          : 20,
                  width: 180,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.only(
                    bottom: 6,
                  ), // Matches the SizedBox(height: 6) in _ProgressDetails
                ),

                // Progress bar (matches ProgressBar widget)
                Container(
                  height: 16, // Matches ProgressBar height
                  margin: const EdgeInsets.only(
                    bottom: 6,
                  ), // Matches the SizedBox(height: 6) in _ProgressDetails
                  child: Row(
                    children: [
                      // Progress bar track and fill
                      Expanded(
                        child: Stack(
                          children: [
                            // Track
                            Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Fill (40% width as a placeholder)
                            FractionallySizedBox(
                              widthFactor: 0.4,
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress text (bodySmall style)
                      const SizedBox(width: 10), // Matches ProgressBar spacing
                      Container(
                        width: 40, // Approximate width for "X/Y" text
                        height:
                            textTheme.bodySmall?.fontSize != null
                                ? textTheme.bodySmall!.fontSize! *
                                    1.4 // Account for line height
                                : 16,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),

                // Info button (matches EpisodeInfoButton)
                Container(
                  height: 36, // Standard button height
                  width: 120, // Approximate width for button with text
                  margin: const EdgeInsets.only(
                    top: 6,
                  ), // Matches the SizedBox(height: 6) in _ProgressDetails
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      18,
                    ), // Standard button border radius
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
