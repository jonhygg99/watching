import 'package:flutter/material.dart';
import 'package:watching/shared/utils/video_utils.dart';
import 'package:watching/shared/widgets/video/video_info.dart';
import 'package:watching/shared/widgets/video/video_thumbnail.dart';

class VideoCard extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onTap;

  const VideoCard({super.key, required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = video['url'] as String? ?? '';
    final videoId = VideoUtils.extractYoutubeVideoId(url);
    final thumbnailUrl = VideoUtils.getYoutubeThumbnailUrl(videoId);

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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: VideoInfo(
                title: video['title'],
                type: video['type'],
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
