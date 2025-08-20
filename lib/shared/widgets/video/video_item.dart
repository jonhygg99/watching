import 'package:flutter/material.dart';
import 'package:watching/shared/utils/video_utils.dart';
import 'package:watching/shared/widgets/video/video_info.dart';
import 'package:watching/shared/widgets/video/video_thumbnail.dart';
import 'package:watching/shared/widgets/video/youtube_player_dialog.dart';

class VideoItem extends StatelessWidget {
  const VideoItem({
    super.key,
    required this.video,
    this.width = 260,
    this.imageHeight = 150,
    this.onTap,
  });

  final Map<String, dynamic> video;
  final double width;
  final double imageHeight;
  final VoidCallback? onTap;

  String? get _youtubeThumbnailUrl {
    if (video['site'] != 'youtube') return null;

    final url = video['url'] as String? ?? '';
    final videoId = VideoUtils.extractYoutubeVideoId(url);

    return VideoUtils.getYoutubeThumbnailUrl(videoId);
  }

  void _showYoutubePlayer(BuildContext context) {
    final url = video['url'] as String?;
    if (url == null) return;

    showDialog(
      context: context,
      builder:
          (_) => YoutubePlayerDialog(url: url, title: video['title'] ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = _youtubeThumbnailUrl;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap ?? () => _showYoutubePlayer(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoThumbnail(
                thumbnailUrl: thumbnailUrl,
                width: width,
                height: imageHeight,
              ),
            ),

            // Video info
            if (video['title'] != null || video['type'] != null) ...[
              const SizedBox(height: 8),
              VideoInfo(title: video['title'], type: video['type']),
            ],
          ],
        ),
      ),
    );
  }
}
