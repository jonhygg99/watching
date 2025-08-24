import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/pages/show_details/details_page.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/utils/get_image.dart';

class ShowGridItem extends ConsumerWidget {
  final Map<String, dynamic> show;
  final List<dynamic> shows;
  final int index;
  final WidgetRef ref;

  const ShowGridItem({
    super.key,
    required this.show,
    required this.shows,
    required this.index,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref
          .read(showTranslationServiceProvider)
          .getTranslatedTitle(show: show, traktApi: ref.read(traktApiProvider)),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        final posterUrl = getFirstAvailableImage(show['images']);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final baseColor =
            (isDark ? kSkeletonBaseColorDark : kSkeletonBaseColorLight)!;
        final highlightColor =
            (isDark
                ? kSkeletonHighlightColorDark
                : kSkeletonHighlightColorLight)!;

        return GestureDetector(
          onTap: () {
            final showId = show['ids']['trakt'].toString();
            if (showId.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShowDetailPage(showId: showId),
                ),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kItemRadius),
                  child:
                      posterUrl != null
                          ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder:
                                (context, url) => Container(
                                  color: baseColor,
                                  child: Shimmer.fromColors(
                                    baseColor: baseColor,
                                    highlightColor: highlightColor,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: baseColor,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: baseColor,
                                  child: const Icon(Icons.error),
                                ),
                          )
                          : Container(
                            color: baseColor,
                            child: const Center(child: Icon(Icons.tv)),
                          ),
                ),
              ),
              const SizedBox(height: kSpaceBtwTitleWidget),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
