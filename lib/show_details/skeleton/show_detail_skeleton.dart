import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'components/skeleton_header.dart';
import 'components/skeleton_episode.dart';
import 'components/skeleton_description.dart';
import 'components/skeleton_cast.dart';
import 'components/skeleton_comments_header.dart';
import 'components/skeleton_videos.dart';
import 'components/skeleton_related_shows.dart';
import 'skeleton_utils.dart';

/// A skeleton loading widget that displays a shimmering placeholder for the show detail page.
/// This matches the layout of the actual ShowDetailPage but with loading placeholders.
class ShowDetailSkeleton extends StatelessWidget {
  const ShowDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: CustomScrollView(
        slivers: [
          const SkeletonHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonEpisode(),
                  const SkeletonSpacer(height: 24),
                  const SkeletonDescription(),
                  const SkeletonSpacer(height: 32),
                  const SkeletonCast(),
                  const SkeletonSpacer(height: 32),
                  const SkeletonCommentsHeader(),
                  const SkeletonSpacer(height: 24),
                  const SkeletonVideos(),
                  const SkeletonSpacer(height: 32),
                  const SkeletonRelatedShows(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
