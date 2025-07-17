import 'package:flutter/material.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'package:watching/shared/widgets/comments_list.dart';

/// Shows a modal bottom sheet with all comments for an episode
Future<void> showEpisodeComments(
  BuildContext context,
  int showId, {
  int? seasonNumber,
  int? episodeNumber,
  String title = 'Comentarios del episodio',
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final sortNotifier = ValueNotifier<String>('newest');
      
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) {
          return ValueListenableBuilder<String>(
            valueListenable: sortNotifier,
            builder: (context, sort, _) {
              return Column(
                children: [
                  AppBar(
                    title: Text(title),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          sortNotifier.value = value;
                        },
                        itemBuilder: (context) => commentSortOptions.entries
                            .map((e) => PopupMenuItem<String>(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        icon: const Icon(Icons.sort),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CommentsList(
                      type: CommentType.episode,
                      id: showId.toString(),
                      seasonNumber: seasonNumber,
                      episodeNumber: episodeNumber,
                      sort: sortNotifier,
                      sortLabels: commentSortOptions,
                      showTitle: false,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

class EpisodeComments extends StatelessWidget {
  final int showId;
  final int seasonNumber;
  final int episodeNumber;

  const EpisodeComments({
    super.key,
    required this.showId,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.comment_outlined),
      onPressed: () => showEpisodeComments(
        context,
        showId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      ),
      tooltip: 'Ver comentarios',
    );
  }
}
