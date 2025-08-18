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
              color: baseColor,
            ),
          ),
          // Title placeholder - matches the actual title style
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              height: 16,
              width: width * titleWidthFactor,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
