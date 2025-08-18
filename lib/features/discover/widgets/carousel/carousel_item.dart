import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/show_details/details_page.dart';

import 'carousel_placeholder_item.dart';
import 'carousel_image_item.dart';

class CarouselItem extends ConsumerWidget {
  const CarouselItem({
    super.key,
    required this.ref,
    required this.context,
    required this.show,
    required this.itemWidth,
    required this.shows,
    required this.index,
  });

  final WidgetRef ref;
  final BuildContext context;
  final Map<String, dynamic> show;
  final double itemWidth;
  final List<dynamic> shows;
  final int index;

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

  // Extracts the show ID in a robust way
  String _getShowId() {
    if (show['ids'] is Map) {
      return show['ids']['trakt']?.toString() ?? '';
    }
    return '';
  }

  void _navigateToDetail() {
    final showId = _getShowId();
    if (showId.isNotEmpty) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ShowDetailPage(showId: showId)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref
          .read(showTranslationServiceProvider)
          .getTranslatedTitle(show: show, traktApi: ref.read(traktApiProvider)),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';

        // Try to get an image, checking multiple image types in order of preference
        final imageUrl = getFirstAvailableImage([
          'poster', // First choice
          'thumb', // Second choice (usually good quality thumbnails)
          'fanart', // Third choice (background images)
          'banner', // Fourth choice (banner images)
        ]);

        return Container(
          width: itemWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image container with flexible height
              Flexible(
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child:
                      imageUrl != null
                          ? CarouselImageItem(
                            imageUrl: imageUrl,
                            onTap: _navigateToDetail,
                            borderRadius: kShowBorderRadius,
                          )
                          : CarouselPlaceholderItem(
                            itemWidth: itemWidth,
                            onTap: _navigateToDetail,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
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
