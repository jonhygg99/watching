import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Data class for a search result (show/movie) using Freezed for immutability and pattern matching.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_result_item.freezed.dart';

@freezed
abstract class SearchResultItem with _$SearchResultItem {
  const factory SearchResultItem({
    required Map<String, dynamic> data,
    required String type, // 'show' or 'movie'
  }) = _SearchResultItem;
}

/// Stateless widget for displaying a single show/movie result in a grid.
class SearchResultGridTile extends StatelessWidget {
  final SearchResultItem item;
  final VoidCallback? onTap;

  const SearchResultGridTile({super.key, required this.item, this.onTap});

  String? _getImageUrl(dynamic imageList) {
    if (imageList is List && imageList.isNotEmpty && imageList.first is String) {
      final url = imageList.first as String;
      if (url.startsWith('http')) return url;
      return 'https://$url';
    }
    return null;
  }

  String? getFirstAvailableImage(Map<String, dynamic>? images) {
    if (images == null) return null;
    
    // Try different image types in order of preference
    for (final type in ['poster', 'thumb', 'fanart', 'banner']) {
      final url = _getImageUrl(images[type]);
      if (url != null) return url;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final show = item.data;
    final imageUrl = getFirstAvailableImage(show['images']);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 0.7,
              child:
                  imageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 48),
                        ),
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            show['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
