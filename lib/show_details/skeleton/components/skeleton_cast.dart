import 'package:flutter/material.dart';
import '../skeleton_utils.dart';

class SkeletonCast extends StatelessWidget {
  const SkeletonCast({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonContainer(
          height: 24,
          width: 100,
          margin: EdgeInsets.only(bottom: 16),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SkeletonContainer(
                    height: 80,
                    width: 80,
                    isCircle: true,
                  ),
                  const SizedBox(height: 8),
                  SkeletonContainer(height: 12, width: 60),
                  const SizedBox(height: 4),
                  SkeletonContainer(height: 10, width: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
