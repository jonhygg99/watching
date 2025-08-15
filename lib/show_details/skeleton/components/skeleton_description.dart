import 'package:flutter/material.dart';
import '../skeleton_utils.dart';

class SkeletonDescription extends StatelessWidget {
  const SkeletonDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonContainer(height: 20, width: double.infinity),
        const SizedBox(height: 8),
        SkeletonContainer(height: 20, width: double.infinity * 0.9),
        const SizedBox(height: 8),
        SkeletonContainer(height: 20, width: double.infinity * 0.7),
      ],
    );
  }
}
