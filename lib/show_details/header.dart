import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowDetailHeader extends StatelessWidget {
  final Map<String, dynamic> show;
  final String title;

  const ShowDetailHeader({super.key, required this.show, required this.title});

  @override
  Widget build(BuildContext context) {
    final images = show['images'] as Map<String, dynamic>? ?? {};
    final fanartUrl =
        images['fanart'] != null && (images['fanart'] as List).isNotEmpty
            ? 'https://${(images['fanart'] as List).first}'
            : null;
    final posterUrl =
        images['poster'] != null && (images['poster'] as List).isNotEmpty
            ? 'https://${(images['poster'] as List).first}'
            : null;

    // Debug prints removed for production

    Widget? buildFanartImage(String? fanartUrl) {
      if (fanartUrl == null) return null;

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: double.infinity,
          height: 170,
          child: CachedNetworkImage(
            imageUrl: fanartUrl,
            fit: BoxFit.cover,
            placeholder:
                (ctx, url) => const Center(child: CircularProgressIndicator()),
            errorWidget:
                (ctx, url, error) => const Icon(
                  Icons.broken_image,
                  size: 80,
                  color: Colors.grey,
                ),
          ),
        ),
      );
    }

    Widget? fanartImage = buildFanartImage(fanartUrl);

    Widget posterImage(String? posterUrl) {
      if (posterUrl == null) {
        return Container(
          height: 170,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[800],
          ),
          child: const Icon(Icons.movie, size: 40, color: Colors.grey),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: posterUrl,
          height: 170,
          width: 120,
          fit: BoxFit.cover,
          placeholder:
              (ctx, url) => const SizedBox(
                height: 170,
                width: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (ctx, url, error) =>
                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    }

    Widget showTitle(String title) {
      return Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      );
    }

    Widget followButton() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          onPressed: () {
            // TODO: Implement follow functionality
          },
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.add, size: 20, color: Colors.white),
        ),
      );
    }

    Widget showMetadata() {
      return Row(
        children: [
          if (show['year'] != null)
            Text('${show['year']}', style: const TextStyle(fontSize: 14)),
          if (show['year'] != null && show['runtime'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text('·', style: TextStyle(fontSize: 16)),
            ),
          if (show['runtime'] != null)
            Text(
              '${show['runtime']} min',
              style: const TextStyle(fontSize: 14),
            ),
          if ((show['year'] != null || show['runtime'] != null) &&
              show['status'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text('·', style: TextStyle(fontSize: 16)),
            ),
          if (show['status'] != null)
            Text(show['status'], style: const TextStyle(fontSize: 14)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fanartImage != null && posterUrl != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              fanartImage,
              Positioned(
                left: 16,
                bottom: -85,
                right: 16, // Add right constraint to prevent overflow
                child: Container(
                  color:
                      Colors.transparent, // Ensure the container takes up space
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      posterImage(posterUrl),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: showTitle(title)),
                                const SizedBox(width: 8),
                                followButton(),
                              ],
                            ),
                            showMetadata(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
