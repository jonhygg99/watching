import 'package:flutter/material.dart';
import 'package:watching/discover/widgets/skeleton/skeleton_carousel_item.dart';
import 'package:watching/shared/constants/measures.dart';

class SkeletonCarouselList extends StatelessWidget {
  const SkeletonCarouselList({
    super.key,
    required this.baseColor,
    this.itemCount = 5,
    this.padding = const EdgeInsets.symmetric(
      horizontal: kSpacePhoneHorizontal,
    ),
    this.separatorWidth = kSpacePhoneHorizontal,
  });

  final Color baseColor;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final double separatorWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: separatorWidth),
        itemBuilder:
            (context, index) => SkeletonCarouselItem(baseColor: baseColor),
      ),
    );
  }
}
