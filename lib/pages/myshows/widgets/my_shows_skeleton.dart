import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyShowsSkeleton extends StatelessWidget {
  const MyShowsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upcoming Episodes Skeleton
            _buildSectionSkeleton(),
            const SizedBox(height: 16),
            ...List.generate(3, (index) => _buildShowItemSkeleton(context)),

            // Waiting Shows Skeleton
            _buildSectionSkeleton(),
            const SizedBox(height: 8),
            _buildGridSkeleton(),

            // Ended Shows Skeleton
            _buildSectionSkeleton(),
            const SizedBox(height: 8),
            _buildGridSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton() {
    return Container(
      width: 200,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShowItemSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Skeleton
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Show Info Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Skeleton
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle Skeleton
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Metadata Skeleton
              ],
            ),
          ),
          // Days Bubble Skeleton
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(left: 8, right: 16),
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6, // Show 6 skeleton items (2 rows of 3)
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
