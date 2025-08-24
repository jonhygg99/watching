import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/pages/show_list/widgets/loading_indicator.dart';
import 'package:watching/shared/pages/show_list/widgets/show_grid_item.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/shared/constants/colors.dart';

class ShowsGrid extends StatelessWidget {
  final ScrollController scrollController;
  final List<dynamic> allShows;
  final bool hasMore;
  final Function(dynamic) extractShow;
  final WidgetRef ref;

  const ShowsGrid({
    super.key,
    required this.scrollController,
    required this.allShows,
    required this.hasMore,
    required this.extractShow,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
    final highlightColor =
        (isDark ? kSkeletonHighlightColorDark : kSkeletonHighlightColorLight)!;

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        kSpacePhoneHorizontal,
        kSpacePhoneHorizontal,
        kSpacePhoneHorizontal,
        hasMore ? kSpacePhoneHorizontal : kPhoneBottomSpacing,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: kSpaceBtwTitleWidget,
        mainAxisSpacing: kSpaceBtwTitleWidget,
        childAspectRatio: 0.65,
      ),
      itemCount: allShows.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading skeleton for the last item when there are more items to load
        if (index >= allShows.length) {
          // return LoadingIndicator();
          return _buildLoadingSkeleton(baseColor, highlightColor);
        }

        final show = extractShow(allShows[index]);
        return ShowGridItem(
          show: show,
          shows: allShows,
          index: index,
          ref: ref,
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(Color baseColor, Color highlightColor) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
