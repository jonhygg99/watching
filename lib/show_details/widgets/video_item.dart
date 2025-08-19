import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/youtube_player_dialog.dart';

class VideoInfo extends StatelessWidget {
  const VideoInfo({
    super.key,
    required this.title,
    this.type,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0),
  });

  final String? title;
  final String? type;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ..._buildTitle(),
          if (type != null) ..._buildType(),
        ],
      ),
    );
  }

  List<Widget> _buildTitle() {
    return [
      Text(
        title!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        ),
      ),
    ];
  }

  List<Widget> _buildType() {
    return [
      const SizedBox(height: 2),
      Text(
        type!.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }
}

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    this.onTap,
  });

  final String? thumbnailUrl;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return thumbnailUrl != null
        ? CachedNetworkImage(
            imageUrl: thumbnailUrl!,
            height: height,
            width: width,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          )
        : _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Icon(
        Icons.videocam,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

class VideoItem extends StatelessWidget {
  const VideoItem({
    super.key,
    required this.video,
    this.width = 260,
    this.imageHeight = 150,
  });

  final Map<String, dynamic> video;
  final double width;
  final double imageHeight;

  String? get _youtubeThumbnailUrl {
    if (video['site'] != 'youtube') return null;
    
    final url = video['url'] ?? '';
    final regExp = RegExp(r'(?:v=|youtu.be/|embed/)([\w-]{11})');
    final match = regExp.firstMatch(url);
    final videoId = match?.group(1);
    
    return videoId != null 
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;
  }

  void _showYoutubePlayer(BuildContext context) {
    if (video['url'] == null) return;
    
    showDialog(
      context: context,
      builder: (_) => YoutubePlayerDialog(
        url: video['url'],
        title: video['title'] ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = _youtubeThumbnailUrl;
    
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play button
          GestureDetector(
            onTap: () => _showYoutubePlayer(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  VideoThumbnail(
                    thumbnailUrl: thumbnailUrl,
                    width: width,
                    height: imageHeight,
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Video info
          if (video['title'] != null || video['type'] != null) ...[
            const SizedBox(height: 8),
            VideoInfo(
              title: video['title'],
              type: video['type'],
            ),
          ],
        ],
      ),
    );
  }
}
