import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';
import 'widgets/header_skeleton.dart';
import 'widgets/details_skeleton.dart';
import 'widgets/actions_skeleton.dart';

class EpisodeInfoModalSkeleton extends StatelessWidget {
  const EpisodeInfoModalSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
    final highlightColor =
        (isDark ? kSkeletonHighlightColorDark : kSkeletonHighlightColorLight)!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              EpisodeHeaderSkeleton(),
              EpisodeDetailsSkeleton(),
              EpisodeActionsSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}
