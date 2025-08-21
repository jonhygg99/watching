import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/episode_header_skeleton.dart';
import 'widgets/episode_details_skeleton.dart';
import 'widgets/episode_actions_skeleton.dart';

class EpisodeInfoModalSkeleton extends StatelessWidget {
  const EpisodeInfoModalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            EpisodeHeaderSkeleton(),
            EpisodeDetailsSkeleton(),
            EpisodeActionsSkeleton(),
          ],
        ),
      ),
    );
  }
}
