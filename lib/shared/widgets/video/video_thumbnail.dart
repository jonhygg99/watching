import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final bool showPlayButton;

  const VideoThumbnail({
    super.key,
    this.thumbnailUrl,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius,
    this.showPlayButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: thumbnailUrl!,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _buildPlaceholder(),
              placeholder: (context, url) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          if (showPlayButton)
            const Icon(
              Icons.play_circle_filled,
              size: 50,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.videocam,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}
