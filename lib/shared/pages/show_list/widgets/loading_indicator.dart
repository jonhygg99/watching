import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.height = 60,
    this.indicatorSize = 24,
    this.alpha = 0.8,
  });

  final double height;
  final double indicatorSize;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
    final highlightColor =
        (isDark ? kSkeletonHighlightColorDark : kSkeletonHighlightColorLight)!;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: height,
        color: theme.scaffoldBackgroundColor.withAlpha((alpha * 255).toInt()),
        child: Center(
          child: SizedBox(
            width: 200,
            height: indicatorSize,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
