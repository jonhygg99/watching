import 'package:flutter/material.dart';
import 'package:watching/show_details/pages/videos/video_thumbnail.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String? type;
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.title,
    this.type,
    this.thumbnailUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VideoThumbnail(
              thumbnailUrl: thumbnailUrl,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
            ),
            _buildVideoInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (type != null) ...[
            const SizedBox(height: 4),
            Text(
              type!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
