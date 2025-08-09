import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';

class ShowListPage extends ConsumerWidget {
  final String title;
  final List<dynamic> shows;
  final dynamic Function(dynamic) extractShow;

  const ShowListPage({
    super.key,
    required this.title,
    required this.shows,
    required this.extractShow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: shows.isEmpty
          ? const Center(child: Text('No shows available'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: shows.length,
              itemBuilder: (context, index) {
                final show = extractShow(shows[index]);
                return _buildShowItem(
                  ref: ref,
                  context: context,
                  show: show,
                  shows: shows,
                  index: index,
                );
              },
            ),
    );
  }

  Widget _buildShowItem({
    required WidgetRef ref,
    required BuildContext context,
    required Map<String, dynamic> show,
    required List<dynamic> shows,
    required int index,
  }) {
    return FutureBuilder<String>(
      future: ref.read(showTranslationServiceProvider).getTranslatedTitle(
            show: show,
            traktApi: ref.read(traktApiProvider),
          ),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        final posterArr = show['images']?['poster'] as List?;
        final posterUrl = (posterArr != null && posterArr.isNotEmpty)
            ? 'https://${posterArr.first}'
            : null;

        return GestureDetector(
          onTap: () {
            final showId = _getShowId(show);
            if (showId.isNotEmpty) {
              // TODO: Navigate to show details when the page is implemented
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => ShowDetailsPage(showId: showId),
              //   ),
              // );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: posterUrl != null
                      ? CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.tv)),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getShowId(Map<String, dynamic> show) {
    if (show['ids']?['trakt'] != null) {
      return show['ids']['trakt'].toString();
    } else if (show['ids']?['slug'] != null) {
      return show['ids']['slug'].toString();
    } else if (show['ids']?['imdb'] != null) {
      return show['ids']['imdb'].toString();
    } else if (show['ids']?['tmdb'] != null) {
      return show['ids']['tmdb'].toString();
    } else if (show['ids']?['tvdb'] != null) {
      return show['ids']['tvdb'].toString();
    }
    return '';
  }
}
