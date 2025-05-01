import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'api_service.dart';
import 'show_details/details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCarousel extends StatelessWidget {
  /// Formatea el conteo para mostrarlo como 1.2k o 3.4M si es necesario
  static String _formatCount(dynamic value) {
    if (value == null) return '';
    int count = 0;
    if (value is int) {
      count = value;
    } else if (value is String) {
      count = int.tryParse(value) ?? 0;
    }
    if (count >= 1000000) {
      return (count / 1000000).toStringAsFixed(count % 1000000 == 0 ? 0 : 1) + 'M';
    } else if (count >= 1000) {
      return (count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1) + 'k';
    } else {
      return count.toString();
    }
  }

  final String title;
  final List<dynamic> shows;
  final String emptyText;
  final dynamic Function(dynamic) extractShow;

  const ShowCarousel({
    super.key,
    required this.title,
    required this.shows,
    required this.extractShow,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final itemWidth = ((screenWidth / 2.2).clamp(140, 260)).toDouble();
            final imageHeight = (itemWidth * 1.3).toDouble();
            final carouselHeight = imageHeight + 30;
            if (shows.isEmpty) {
              return SizedBox(
                height: carouselHeight,
                child: Center(child: Text(emptyText)),
              );
            }
            return SizedBox(
              height: carouselHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: shows.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _buildShowItem(
                  context: context,
                  show: extractShow(shows[index]),
                  itemWidth: itemWidth,
                  imageHeight: imageHeight,
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
    required BuildContext context,
    required Map<String, dynamic> show,
    required double itemWidth,
    required double imageHeight,
    required List<dynamic> shows,
    required int index,
  }) {
    final title = show['title'] ?? '';
    final posterArr = show['images']?['poster'] as List?;
    final posterUrl = (posterArr != null && posterArr.isNotEmpty)
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
                      // Obtener el countryCode guardado
                      String countryCode = 'ES';
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        countryCode = prefs.getString('country_code') ?? 'ES';
                      } catch (_) {}
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowDetailPage(
                            showId: showId,
                            apiService: ApiService(),
                            countryCode: countryCode,
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: posterUrl,
                          width: itemWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SizedBox(
                            width: itemWidth,
                            height: imageHeight,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                      if (shows[index]['user_count'] != null || shows[index]['play_count'] != null || shows[index]['watcher_count'] != null || shows[index]['collected_count'] != null || shows[index]['list_count'] != null)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (shows[index]['user_count'] != null) ...[
                                  const Icon(Icons.favorite, color: Colors.pinkAccent, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatCount(shows[index]['user_count']),
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (shows[index]['play_count'] != null) ...[
                                  const Icon(Icons.play_circle_fill, color: Colors.lightBlueAccent, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatCount(shows[index]['play_count']),
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (shows[index]['watcher_count'] != null) ...[
                                  const Icon(Icons.visibility, color: Colors.amber, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatCount(shows[index]['watcher_count']),
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (shows[index]['collected_count'] != null) ...[
                                  const Icon(Icons.collections_bookmark, color: Colors.deepPurpleAccent, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatCount(shows[index]['collected_count']),
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                if (shows[index]['list_count'] != null) ...[
                                  const Icon(Icons.star_outline, color: Colors.orange, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatCount(shows[index]['list_count']),
                                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Icon(Icons.tv, size: itemWidth / 2, color: Colors.grey),
                    const SizedBox(height: 4),
                    const Text('Sin imagen', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            softWrap: true,
          ),
        ],
      ),
    );
  }

  // Extrae el showId de forma robusta
  String _getShowId(Map<String, dynamic> show) {
    final ids = show['ids'] as Map?;
    if (ids == null) return '';
    return ids['slug'] ?? ids['trakt']?.toString() ?? ids['imdb'] ?? '';
  }

  // Widget de badges de contadores
  Widget _buildBadges(Map<String, dynamic> show) {
    final badgeItems = <Widget>[];
    void addBadge(Icon icon, dynamic count) {
      badgeItems.addAll([
        icon,
        const SizedBox(width: 3),
        Text(
          _formatCount(count),
          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
      ]);
    }
    if (show['user_count'] != null) {
      addBadge(const Icon(Icons.favorite, color: Colors.pinkAccent, size: 14), show['user_count']);
    }
    if (show['play_count'] != null) {
      addBadge(const Icon(Icons.play_circle_fill, color: Colors.lightBlueAccent, size: 14), show['play_count']);
    }
    if (show['watcher_count'] != null) {
      addBadge(const Icon(Icons.visibility, color: Colors.amber, size: 14), show['watcher_count']);
    }
    if (show['collected_count'] != null) {
      addBadge(const Icon(Icons.collections_bookmark, color: Colors.deepPurpleAccent, size: 14), show['collected_count']);
    }
    if (show['list_count'] != null) {
      badgeItems.addAll([
        const Icon(Icons.star_outline, color: Colors.orange, size: 14),
        const SizedBox(width: 3),
        Text(
          _formatCount(show['list_count']),
          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ]);
    }
    if (badgeItems.isEmpty) return const SizedBox.shrink();
    // Elimina el último SizedBox(width: 10)
    if (badgeItems.length > 3 && badgeItems.last is SizedBox) {
      badgeItems.removeLast();
    }
    return Positioned(
      right: 6,
      top: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: badgeItems,
        ),
      ),
    );
  }
}

