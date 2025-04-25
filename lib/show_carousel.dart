import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowCarousel extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> future;
  final String emptyText;
  final dynamic Function(dynamic) extractShow;

  const ShowCarousel({
    super.key,
    required this.title,
    required this.future,
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
            return SizedBox(
              height: carouselHeight,
              child: FutureBuilder<List<dynamic>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: \\${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  final shows = snapshot.data;
                  if (shows == null || shows.isEmpty) {
                    return Text(emptyText);
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: shows.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final show = extractShow(shows[index]);
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
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: posterUrl,
                                      width: itemWidth,
                                      height: imageHeight,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => SizedBox(
                                        width: itemWidth, height: imageHeight,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 48),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Icon(Icons.tv, size: itemWidth/2, color: Colors.grey),
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
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
