import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'services/episode_rating_service.dart';
import 'widgets/episode_header.dart';
import 'widgets/episode_details.dart';
import 'widgets/episode_actions.dart';
import 'package:watching/shared/widgets/comments_list.dart';
import 'package:watching/shared/constants/sort_options.dart';

class EpisodeInfoModal extends StatefulWidget {
  final Future<Map<String, dynamic>> episodeFuture;
  final Map<String, dynamic> showData;
  final int seasonNumber;
  final int episodeNumber;
  final void Function()? onWatchedStatusChanged;

  const EpisodeInfoModal({
    super.key,
    required this.episodeFuture,
    required this.showData,
    required this.seasonNumber,
    required this.episodeNumber,
    this.onWatchedStatusChanged,
  });

  @override
  State<EpisodeInfoModal> createState() => _EpisodeInfoModalState();
}

class _EpisodeInfoModalState extends State<EpisodeInfoModal> {
  double? episodeRating;
  bool _isRating = false;
  bool? _isWatched;
  late final EpisodeRatingService _ratingService;
  late final TraktApi _traktApi;

  @override
  void initState() {
    super.initState();
    _traktApi = TraktApi();
    _ratingService = EpisodeRatingService(_traktApi);
    _loadWatchedStatus();
  }

  Future<void> _loadWatchedStatus() async {
    try {
      final showId = widget.showData['ids']['trakt']?.toString();
      if (showId == null) return;

      final progress = await _traktApi.getShowWatchedProgress(id: showId);
      final seasons = progress['seasons'] as List<dynamic>?;

      if (seasons != null) {
        for (final season in seasons) {
          if (season['number'] == widget.seasonNumber) {
            final episodes = season['episodes'] as List<dynamic>?;
            if (episodes != null) {
              final episode = episodes.firstWhere(
                (e) => e['number'] == widget.episodeNumber,
                orElse: () => null,
              );
              if (episode != null && mounted) {
                setState(() {
                  _isWatched = episode['completed'] == true;
                });
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

  Future<void> _handleRatingUpdate(double? newRating) async {
    // If we're already processing a rating update, queue this one
    if (_isRating) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isRating) {
        // If still processing after delay, ignore this update
        return;
      }
    }

    setState(() {
      _isRating = true;
      episodeRating = (newRating != null && newRating > 0) ? newRating : null;
    });

    try {
      if (newRating != null && newRating > 0) {
        await _addRating(newRating);
      } else {
        await _removeRating();
      }
    } catch (e) {
      debugPrint('Error updating rating: $e');
      // Revert the UI if the API call fails
      if (mounted) {
        setState(() {
          episodeRating = episodeRating == 0 ? null : episodeRating;
        });
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isRating = false;
        });
      }
    }
  }

  Future<void> _addRating(double rating) async {
    await _ratingService.addRating(
      showData: widget.showData,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
      rating: rating,
    );
  }

  Future<void> _removeRating() async {
    await _ratingService.removeRating(
      showData: widget.showData,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
    );
  }

  Future<void> _handleWatchedStatusChanged(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> episode,
    bool newWatchedState,
  ) async {
    final notifier = ref.read(watchlistProvider.notifier);
    final showId = widget.showData['ids']['trakt']?.toString() ?? '';

    try {
      await notifier.toggleEpisodeWatchedStatus(
        showTraktId: showId,
        seasonNumber: widget.seasonNumber,
        episodeNumber: widget.episodeNumber,
        watched: newWatchedState,
      );

      // Update local state
      if (mounted) {
        setState(() {
          _isWatched = newWatchedState;
        });

        // Notify parent about the watched status change
        if (widget.onWatchedStatusChanged != null) {
          widget.onWatchedStatusChanged!();
        }
      }
    } catch (e) {
      // Error handled silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.episodeFuture,
      builder: (context, snapshot) {
        Widget content;

        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          content = Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final episode = snapshot.data;
          if (episode == null) {
            content = const SizedBox.shrink();
          } else {
            // Merge the watched status into the episode data
            final episodeWithWatched = Map<String, dynamic>.from(episode);
            if (_isWatched != null) {
              episodeWithWatched['watched'] = _isWatched;
            }

            final img = _getScreenshotUrl(episodeWithWatched);
            final imageUrl =
                img != null
                    ? (img is String && !img.startsWith('http')
                        ? 'https://$img'
                        : img)
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
                      showData: widget.showData,
                      seasonNumber: widget.seasonNumber,
                      episodeNumber: widget.episodeNumber,
                      currentRating: episodeRating,
                      onRatingChanged: _handleRatingUpdate,
                      onWatchedStatusChanged: (isWatched) async {
                        await _handleWatchedStatusChanged(
                          context,
                          ref,
                          episodeWithWatched,
                          isWatched,
                        );
                        // Refresh the watched status after toggling
                        await _loadWatchedStatus();
                      },
                      onCommentsPressed: () {
                        final sortNotifier = ValueNotifier<String>('likes');
                        showAllComments(
                          context,
                          widget.showData['ids']['trakt'].toString(),
                          sortNotifier,
                          commentSortOptions,
                          ref,
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

  dynamic _getScreenshotUrl(Map<String, dynamic> episode) {
    if (episode['images']?['screenshot'] is List &&
        (episode['images']?['screenshot'] as List).isNotEmpty) {
      return episode['images']['screenshot'][0];
    }
    return null;
  }
}
