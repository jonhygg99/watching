import 'package:flutter/material.dart';
import 'skeleton_utils.dart';

class SkeletonRelatedShows extends StatelessWidget {
  const SkeletonRelatedShows({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonContainer(
          height: 24,
          width: 150,
          margin: EdgeInsets.only(bottom: 16),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SkeletonContainer(height: 220, width: 140, radius: 12),
                ),
          ),
        ),
      ],
    );
  }
}
