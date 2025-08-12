import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/shared/constants/measures.dart';
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewMore != null)
                TextButton(
                  onPressed: onViewMore,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Ver más',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = kDiscoverShowImageHeight + 50;
            if (shows.isEmpty) {
              return SizedBox(
                height: carouselHeight,
                child: Center(child: Text(emptyText)),
              );
            }
            return SizedBox(
              height: carouselHeight,
              child: ListView.separated(
                key: _pageStorageKey,
                scrollDirection: Axis.horizontal,
                itemCount: shows.length,
                cacheExtent: 1000, // Cache more items offscreen for smoother scrolling
                addAutomaticKeepAlives: true, // Preserve scroll position
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _buildShowItem(
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
      future: ref.read(showTranslationServiceProvider).getTranslatedTitle(
            show: show,
            traktApi: ref.read(traktApiProvider),
          ),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        final posterArr = show['images']?['poster'] as List?;
        final posterUrl =
            (posterArr != null && posterArr.isNotEmpty)
                ? 'https://${posterArr.first}'
                : null;
        return SizedBox(
          width: itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              posterUrl != null
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
                          imageUrl: posterUrl,
                          width: itemWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => SizedBox(
                                    width: itemWidth,
                                    height: imageHeight,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Icon(Icons.tv, size: itemWidth / 2, color: Colors.grey),
                        const SizedBox(height: 4),
                        const Text(
                          'Sin imagen',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
              const SizedBox(height: 4),
              SizedBox(
                width: itemWidth - 8, // Slightly less than full width for padding
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.2,
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
