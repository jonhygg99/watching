import 'package:flutter/material.dart';
import 'skeleton_utils.dart';

class SkeletonVideos extends StatelessWidget {
  const SkeletonVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonContainer(
      height: 200,
      width: double.infinity,
      radius: 12,
    );
  }
}
