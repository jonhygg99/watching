import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/shared/utils/get_image.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'services/episode_rating_service.dart';
import 'widgets/episode_header.dart';
import 'widgets/episode_details.dart';
import 'widgets/episode_actions.dart';
import '../comments/widgets/comments_modal.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'skeleton/episode_info_modal_skeleton.dart';

class EpisodeInfoModal extends HookConsumerWidget {
  const EpisodeInfoModal({
    super.key,
    required this.episodeFuture,
    required this.showData,
    required this.seasonNumber,
    required this.episodeNumber,
    this.onWatchedStatusChanged,
  });

  final Future<Map<String, dynamic>> episodeFuture;
  final Map<String, dynamic> showData;
  final int seasonNumber;
  final int episodeNumber;
  final void Function()? onWatchedStatusChanged;

  Future<void> _loadWatchedStatus(
    TraktApi traktApi,
    ValueNotifier<bool?> isWatchedNotifier,
  ) async {
    try {
      final showId = showData['ids']['trakt']?.toString();
      if (showId == null) return;

      final progress = await traktApi.getShowWatchedProgress(id: showId);
      final seasons = progress['seasons'] as List<dynamic>?;

      if (seasons != null) {
        for (final season in seasons) {
          if (season['number'] == seasonNumber) {
            final episodes = season['episodes'] as List<dynamic>?;
            if (episodes != null) {
              final episode = episodes.firstWhere(
                (e) => e['number'] == episodeNumber,
                orElse: () => null,
              );
              if (episode != null) {
                isWatchedNotifier.value = episode['completed'] == true;
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading watched status: $e');
    }
  }

  Future<void> _handleRatingUpdate(
    double? newRating, {
    required ValueNotifier<bool> isRating,
    required ValueNotifier<double?> currentRating,
    required EpisodeRatingService ratingService,
  }) async {
    if (isRating.value) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (isRating.value) return;
    }

    isRating.value = true;
    currentRating.value =
        (newRating != null && newRating > 0) ? newRating : null;

    try {
      if (newRating != null && newRating > 0) {
        await _addRating(newRating, ratingService);
      } else {
        await _removeRating(ratingService);
      }
    } catch (e) {
      debugPrint('Error updating rating: $e');
      currentRating.value =
          currentRating.value == 0 ? null : currentRating.value;
      rethrow;
    } finally {
      isRating.value = false;
    }
  }

  Future<void> _addRating(
    double rating,
    EpisodeRatingService ratingService,
  ) async {
    await ratingService.addRating(
      showData: showData,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      rating: rating,
    );
  }

  Future<void> _removeRating(EpisodeRatingService ratingService) async {
    await ratingService.removeRating(
      showData: showData,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
  }

  Future<void> _handleWatchedStatusChanged(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> episode,
    bool newWatchedState, {
    required ValueNotifier<bool?> isWatchedNotifier,
    required void Function()? onWatchedStatusChanged,
  }) async {
    final notifier = ref.read(watchlistProvider.notifier);
    final showId = showData['ids']['trakt']?.toString() ?? '';

    try {
      await notifier.toggleEpisodeWatchedStatus(
        showTraktId: showId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        watched: newWatchedState,
      );

      isWatchedNotifier.value = newWatchedState;
      onWatchedStatusChanged?.call();
    } catch (e) {
      // Error handled silently
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeRating = useState<double?>(null);
    final isRating = useState(false);
    final isWatched = useState<bool?>(null);
    final traktApi = useMemoized(() => TraktApi());
    final ratingService = useMemoized(() => EpisodeRatingService(traktApi), [
      traktApi,
    ]);

    useEffect(() {
      _loadWatchedStatus(traktApi, isWatched);
      return null;
    }, [traktApi]);

    final episodeFutureState = useState<Future<Map<String, dynamic>>>(
      episodeFuture,
    );

    useEffect(() {
      episodeFutureState.value = episodeFuture;
      return null;
    }, [episodeFuture]);

    return FutureBuilder<Map<String, dynamic>>(
      future: episodeFutureState.value,
      builder: (context, snapshot) {
        Widget content;

        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const EpisodeInfoModalSkeleton();
        } else if (snapshot.hasError) {
          content = Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final episode = snapshot.data;
          if (episode == null) {
            content = const SizedBox.shrink();
          } else {
            // Merge the watched status into the episode data
            final episodeWithWatched = Map<String, dynamic>.from(episode);
            if (isWatched.value != null) {
              episodeWithWatched['watched'] = isWatched.value;
            }

            final img = getScreenshotUrl(episodeWithWatched);
            final imageUrl =
                img != null
                    ? (!img.startsWith('http') ? 'https://$img' : img)
                    : null;

            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EpisodeHeader(episode: episodeWithWatched, imageUrl: imageUrl),
                EpisodeDetails(episode: episodeWithWatched),
                Consumer(
                  builder: (context, ref, _) {
                    return EpisodeActions(
                      episode: episodeWithWatched,
                      showData: showData,
                      seasonNumber: seasonNumber,
                      episodeNumber: episodeNumber,
                      currentRating: episodeRating.value,
                      onRatingChanged:
                          (rating) => _handleRatingUpdate(
                            rating,
                            isRating: isRating,
                            currentRating: episodeRating,
                            ratingService: ratingService,
                          ),
                      onWatchedStatusChanged:
                          (isWatchedValue) => _handleWatchedStatusChanged(
                            context,
                            ref,
                            episodeWithWatched,
                            isWatchedValue,
                            isWatchedNotifier: isWatched,
                            onWatchedStatusChanged: onWatchedStatusChanged,
                          ),
                      onCommentsPressed: () {
                        final sortNotifier = ValueNotifier<String>('likes');
                        CommentsModal.show(
                          context,
                          showId: showData['ids']['trakt'].toString(),
                          sort: sortNotifier,
                          sortKeys: commentSortOptions.keys.toList(),
                          ref: ref,
                          seasonNumber: seasonNumber,
                          episodeNumber: episodeNumber,
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(child: content),
        );
      },
    );
  }
}
