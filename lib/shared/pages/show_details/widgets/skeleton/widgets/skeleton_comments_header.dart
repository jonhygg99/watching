import 'package:flutter/material.dart';
import 'skeleton_utils.dart';

class SkeletonCommentsHeader extends StatelessWidget {
  const SkeletonCommentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SkeletonContainer(height: 24, width: 150),
        SkeletonContainer(height: 24, width: 120, radius: 16),
      ],
    );
  }
}
