import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watching/shared/constants/measures.dart';

class ShowDetailHeader extends StatelessWidget {
  final Map<String, dynamic> show;
  final String title;

  const ShowDetailHeader({super.key, required this.show, required this.title});

  @override
  Widget build(BuildContext context) {
    final images = show['images'] as Map<String, dynamic>? ?? {};
    final fanartUrl =
        images['fanart'] != null && (images['fanart'] as List).isNotEmpty
            ? 'https://${(images['fanart'] as List).first}'
            : null;
    final showImageUrl =
        images['poster'] != null && (images['poster'] as List).isNotEmpty
            ? 'https://${(images['poster'] as List).first}'
            : null;

    Widget? buildFanartImage(String? fanartUrl) {
      if (fanartUrl == null) return null;

      return ClipRRect(
        borderRadius: kShowPosterBorderRadius,
        child: SizedBox(
          width: double.infinity,
          height: kMyShowImageHeight,
          child: CachedNetworkImage(
            imageUrl: fanartUrl,
            fit: BoxFit.cover,
            placeholder:
                (ctx, url) => const Center(child: CircularProgressIndicator()),
            errorWidget:
                (ctx, url, error) => const Icon(
                  Icons.broken_image,
                  size: 80,
                  color: Colors.grey,
                ),
          ),
        ),
      );
    }

    Widget? fanartImage = buildFanartImage(fanartUrl);

    Widget showImage(String? showImageUrl) {
      if (showImageUrl == null) {
        return Container(
          height: kMyShowImageHeight,
          width: kMyShowItemWidth,
          decoration: BoxDecoration(
            borderRadius: kShowBorderRadius,
            color: Colors.grey[800],
          ),
          child: const Icon(Icons.movie, size: 40, color: Colors.grey),
        );
      }

      return ClipRRect(
        borderRadius: kShowBorderRadius,
        child: CachedNetworkImage(
          imageUrl: showImageUrl,
          height: kMyShowImageHeight,
          width: kMyShowItemWidth,
          fit: BoxFit.cover,
          placeholder:
              (ctx, url) => const SizedBox(
                height: kMyShowImageHeight,
                width: kMyShowItemWidth,
                child: Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (ctx, url, error) =>
                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    }

    Widget showTitle(String title) {
      return Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
    }

    Widget showMetadata() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (show['year'] != null)
              Text(
                '${show['year']}',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.visible,
              ),
            if (show['year'] != null && show['runtime'] != null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('·', style: TextStyle(fontSize: 16)),
              ),
            if (show['runtime'] != null)
              Text(
                '${show['runtime']} min',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.visible,
              ),
            if ((show['year'] != null || show['runtime'] != null) &&
                show['status'] != null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text('·', style: TextStyle(fontSize: 16)),
              ),
            if (show['status'] != null)
              Text(
                show['status'],
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.visible,
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fanartImage != null && showImageUrl != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              fanartImage,
              Positioned(
                left: 16,
                bottom: -95,
                right: 16,
                child: SizedBox(
                  height: 170, // Match the height of the poster image
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      showImage(showImageUrl),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 65),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 65,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        showTitle(title),
                                        showMetadata(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
