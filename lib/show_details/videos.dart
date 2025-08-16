import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../youtube_player_dialog.dart';
import 'all_videos_page.dart';

class ShowDetailVideos extends StatelessWidget {
  final List<dynamic>? videos;
  final String title;

  const ShowDetailVideos({
    super.key,
    required this.videos,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (videos == null || videos!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vídeos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              if (videos != null && videos!.length > 1)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AllVideosPage(
                              videos: videos!,
                              showTitle: title,
                            ),
                      ),
                    );
                  },
                  child: const Text('Ver todos'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: videos!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final v = videos![i];
                final isYoutube =
                    v['site'] == 'youtube' ||
                    (v['url'] ?? '').contains('youtube.com') ||
                    (v['url'] ?? '').contains('youtu.be');
                if (!isYoutube) return const SizedBox.shrink();
                String? thumbnailUrl;
                final url = v['url'] ?? '';
                final regExp = RegExp(r'(?:v=|youtu.be/|embed/)([\w-]{11})');
                final match = regExp.firstMatch(url);
                final videoId = match?.group(1);
                if (videoId != null) {
                  thumbnailUrl =
                      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
                }
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => YoutubePlayerDialog(
                            url: url,
                            title: v['title'] ?? '',
                          ),
                    );
                  },
                  child: SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              thumbnailUrl != null
                                  ? CachedNetworkImage(
                                    imageUrl: thumbnailUrl,
                                    height: 150,
                                    width: 260,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    height: 150,
                                    width: 260,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.videocam,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v['title'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                              if (v['type'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  (v['type'] as String).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
