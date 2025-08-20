import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/widgets/carousel/app_carousel.dart';
import 'package:watching/shared/widgets/video/video_item.dart';
import 'package:watching/show_details/pages/videos/videos_page.dart';

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

    return AppCarousel<dynamic>(
      title: AppLocalizations.of(context)!.videos,
      items: videos!,
      itemBuilder: (context, video) => VideoItem(video: video),
      itemHeight: 220,
      emptyText: AppLocalizations.of(context)!.noVideosAvailable,
      onViewMore: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideosPage(videos: videos!, showTitle: title),
          ),
        );
      },
    );
  }
}
