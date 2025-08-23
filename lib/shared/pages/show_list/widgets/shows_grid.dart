import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/utils/get_image.dart';
import 'package:watching/shared/pages/show_details/details_page.dart'
    show ShowDetailPage;

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
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        kSpacePhoneHorizontal,
        kSpacePhoneHorizontal,
        kSpacePhoneHorizontal,
        hasMore ? kSpacePhoneHorizontal : kBottomNavigationBarHeight,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: kSpaceBtwTitleWidget,
        mainAxisSpacing: kSpaceBtwTitleWidget,
        childAspectRatio: 0.65,
      ),
      itemCount: allShows.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= allShows.length) {
          return const SizedBox.shrink();
        }

        final show = extractShow(allShows[index]);
        return _buildShowItem(
          ref: ref,
          context: context,
          show: show,
          shows: allShows,
          index: index,
        );
      },
    );
  }

  Widget _buildShowItem({
    required WidgetRef ref,
    required BuildContext context,
    required Map<String, dynamic> show,
    required List<dynamic> shows,
    required int index,
  }) {
    return FutureBuilder<String>(
      future: ref
          .read(showTranslationServiceProvider)
          .getTranslatedTitle(show: show, traktApi: ref.read(traktApiProvider)),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        final posterUrl = getFirstAvailableImage(show['images']);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

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
                                  color:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color:
                                      isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                          )
                          : Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
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
