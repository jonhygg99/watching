import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final double height;
  final double width;
  final BorderRadius? borderRadius;

  const VideoThumbnail({
    super.key,
    this.thumbnailUrl,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (thumbnailUrl != null)
          ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: CachedNetworkImage(
              imageUrl: thumbnailUrl!,
              height: height,
              width: width,
              fit: BoxFit.cover,
              errorWidget: _buildErrorWidget,
            ),
          )
        else
          _buildPlaceholder(),
        const Icon(Icons.play_circle_filled, size: 60, color: Colors.white),
      ],
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
      child: const Icon(Icons.videocam, size: 50),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String url, dynamic error) {
    return _buildPlaceholder();
  }
}
