import 'package:flutter/material.dart';
import 'package:watching/shared/constants/measures.dart';

class SkeletonCarouselHeader extends StatelessWidget {
  const SkeletonCarouselHeader({
    super.key,
    required this.baseColor,
    this.titleWidth = 150,
    this.actionWidth = 50,
    this.height = 24,
  });

  final Color baseColor;
  final double titleWidth;
  final double actionWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacePhoneHorizontal,
        vertical: kSpaceBtwTitleWidget,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSkeletonBox(titleWidth, height),
          _buildSkeletonBox(actionWidth, height),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
