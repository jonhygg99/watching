import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/widgets/carousel/skeleton/skeleton_carousel_header.dart';
import 'package:watching/shared/widgets/carousel/skeleton/skeleton_carousel_item.dart';
import 'package:watching/shared/constants/measures.dart';

/// A skeleton loading widget for discover page carousels that matches the actual UI
class DiscoverSkeleton extends StatelessWidget {
  /// Creates a skeleton that matches the [Carousel] widget's structure
  const DiscoverSkeleton({super.key, this.title = '', this.itemCount = 5});

  /// Title to display in the skeleton header
  final String title;

  /// Number of skeleton items to show in the carousel
  final int itemCount;

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
      period: const Duration(milliseconds: 1500),
      child: _buildSkeletonCarousel(context),
    );
  }

  Widget _buildSkeletonCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonCarouselHeader(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        SizedBox(
          height: kDiscoverShowImageHeight + 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: kSpacePhoneHorizontal),
            itemCount: 1,
            itemBuilder: (context, _) {
              return Row(
                children: List.generate(
                  itemCount,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: kSpaceCarousel),
                    child: SkeletonCarouselItem(
                      baseColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
