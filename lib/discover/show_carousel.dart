import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/constants/fonts.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/show_details/details_page.dart';

class ShowCarousel extends ConsumerWidget {
  final String title;
  final List<dynamic> shows;
  final String emptyText;
  final dynamic Function(dynamic) extractShow;
  final VoidCallback? onViewMore;
  final PageStorageKey _pageStorageKey;

  ShowCarousel({
    super.key,
    required this.title,
    required this.shows,
    required this.extractShow,
    required this.emptyText,
    this.onViewMore,
  }) : _pageStorageKey = PageStorageKey<String>('carousel_$title');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: kSpaceBtwTitleWidget / 2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacePhone),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: kMediumTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onViewMore != null)
                  TextButton(
                    onPressed: onViewMore,
                    child: Text(
                      AppLocalizations.of(context)?.viewMore ?? 'View More',
                      style: const TextStyle(
                        fontSize: kFontSizeButtonTextViewMore,
                        color: kButtonTextViewMoreColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = kDiscoverShowImageHeight + 40;
            if (shows.isEmpty) {
              return SizedBox(
                height: carouselHeight,
                child: Center(child: Text(emptyText)),
              );
            }
            return SizedBox(
              height: carouselHeight,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: kSpacePhone),
                clipBehavior: Clip.none,
                key: _pageStorageKey,
                scrollDirection: Axis.horizontal,
                itemCount: shows.length,
                cacheExtent:
                    1000, // Cache more items offscreen for smoother scrolling
                addAutomaticKeepAlives: true, // Preserve scroll position
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder:
                    (context, index) => _buildShowItem(
                      ref: ref,
                      context: context,
                      show: extractShow(shows[index]),
                      itemWidth: kDiscoverShowItemWidth,
                      imageHeight: kDiscoverShowImageHeight,
                      shows: shows,
                      index: index,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Widget privado para un show ---
  Widget _buildShowItem({
    required WidgetRef ref,
    required BuildContext context,
    required Map<String, dynamic> show,
    required double itemWidth,
    required double imageHeight,
    required List<dynamic> shows,
    required int index,
  }) {
    // Use a FutureBuilder to handle the async translation
    return FutureBuilder<String>(
      future: ref
          .read(showTranslationServiceProvider)
          .getTranslatedTitle(show: show, traktApi: ref.read(traktApiProvider)),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        // Helper function to get first available image from a list of image types
        String? getFirstAvailableImage(List<String> imageTypes) {
          for (final type in imageTypes) {
            final images = show['images']?[type] as List?;
            if (images != null && images.isNotEmpty) {
              return 'https://${images.first}';
            }
          }
          return null;
        }

        // Try to get an image, checking multiple image types in order of preference
        final imageUrl = getFirstAvailableImage([
          'poster', // First choice
          'thumb', // Second choice (usually good quality thumbnails)
          'fanart', // Third choice (background images)
          'banner', // Fourth choice (banner images)
        ]);
        return SizedBox(
          width: itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              imageUrl != null
                  ? GestureDetector(
                    onTap: () async {
                      final showId = _getShowId(show);
                      if (showId.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShowDetailPage(showId: showId),
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: kShowBorderRadius,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: itemWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => SizedBox(
                              width: itemWidth,
                              height: imageHeight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  )
                  : GestureDetector(
                    onTap: () {
                      final showId = _getShowId(show);
                      if (showId.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ShowDetailPage(showId: showId),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: itemWidth,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: kShowBorderRadius,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tv,
                            size: itemWidth / 3,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sin imagen',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 4),
              SizedBox(
                width:
                    itemWidth - 8, // Slightly less than full width for padding
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: kFontSizeShowTitle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Extrae el showId de forma robusta
  String _getShowId(Map<String, dynamic> show) {
    final ids = show['ids'] as Map?;
    if (ids == null) return '';
    return ids['slug'] ?? ids['trakt']?.toString() ?? ids['imdb'] ?? '';
  }
}
