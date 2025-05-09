import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Data class for a search result (show/movie) using Freezed for immutability and pattern matching.
import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_result_item.freezed.dart';

@freezed
class SearchResultItem with _$SearchResultItem {
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

  String? getPosterUrl(dynamic posterList) {
    if (posterList is List &&
        posterList.isNotEmpty &&
        posterList.first is String) {
      final url = posterList.first as String;
      if (url.startsWith('http')) return url;
      return 'https://$url';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final show = item.data;
    final poster = getPosterUrl(show['images']?['poster']);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 0.7,
              child:
                  poster != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: poster,
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
