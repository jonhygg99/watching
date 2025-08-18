import 'package:flutter/material.dart';
import 'package:watching/shared/constants/measures.dart';

class SkeletonCarouselItem extends StatelessWidget {
  const SkeletonCarouselItem({
    super.key,
    required this.baseColor,
    this.width = kDiscoverShowItemWidth,
    this.imageHeight = kDiscoverShowImageHeight,
    this.titleWidthFactor = 0.7,
  });

  final Color baseColor;
  final double width;
  final double imageHeight;
  final double titleWidthFactor;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder - matches the actual image container
          ClipRRect(
            borderRadius: kShowBorderRadius,
            child: Container(
              width: width,
              height: imageHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: kShowBorderRadius,
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Title placeholder - matches the actual title style
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Container(
                height: 20,
                width: width * titleWidthFactor,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
