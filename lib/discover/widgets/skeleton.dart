import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/discover/widgets/skeleton/skeleton_carousel_header.dart';
import 'package:watching/discover/widgets/skeleton/skeleton_carousel_list.dart';
import 'package:watching/shared/constants/measures.dart';

/// A skeleton loading widget for discover page carousels that matches the actual UI
class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate carousel height to fit the image and text
        final carouselHeight = kDiscoverShowImageHeight + 40;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
        final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1500),
          child: SizedBox(
            width: double.infinity,
            height: carouselHeight + 40, // Extra space for the title
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonCarouselHeader(baseColor: baseColor),
                SkeletonCarouselList(baseColor: baseColor),
              ],
            ),
          ),
        );
      },
    );
  }
}
