import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/carousel/widgets/carousel_header.dart';
import 'package:watching/show_details/widgets/video_item.dart';
import 'package:watching/show_details/pages/all_videos_page.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselHeader(
          title: AppLocalizations.of(context)!.videos,
          onViewMore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        AllVideosPage(videos: videos!, showTitle: title),
              ),
            );
          },
        ),
        const SizedBox(height: kSpaceBtwTitleWidget),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: kSpacePhoneHorizontal),
              child: Row(
                children:
                    videos!.map((video) {
                      return Padding(
                        padding: const EdgeInsets.only(right: kSpaceCarousel),
                        child: VideoItem(video: video),
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
