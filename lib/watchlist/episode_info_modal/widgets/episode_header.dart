import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EpisodeHeader extends StatelessWidget {
  final Map<String, dynamic> episode;
  final String? imageUrl;

  const EpisodeHeader({
    super.key,
    required this.episode,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                episode['title'] ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Text(
              'T${episode['season']}E${episode['number']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
