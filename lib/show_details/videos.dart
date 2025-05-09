import 'package:flutter/material.dart';
import '../youtube_player_dialog.dart';

class ShowDetailVideos extends StatelessWidget {
  final List<dynamic>? videos;
  const ShowDetailVideos({super.key, this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos == null || videos!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vídeos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: videos!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              thumbnailUrl != null
                                  ? Image.network(
                                    thumbnailUrl,
                                    height: 90,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    height: 90,
                                    width: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.videocam,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            v['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          v['type'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
