import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'services/episode_rating_service.dart';
import 'widgets/episode_header.dart';
import 'widgets/episode_details.dart';
import 'widgets/episode_actions.dart';
import 'widgets/episode_comments.dart';

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
  late final EpisodeRatingService _ratingService;
  late final TraktApi _traktApi;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _traktApi = TraktApi();
    _ratingService = EpisodeRatingService(_traktApi);
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
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
          episode['watched'] = newWatchedState;
        });

        // Notify parent about the watched status change
        if (widget.onWatchedStatusChanged != null) {
          widget.onWatchedStatusChanged!();
        }
      }
    } catch (e) {
      // Error handled silently
      debugPrint('Error toggling watched status: $e');
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
            final img = _getScreenshotUrl(episode);
            final imageUrl =
                img != null
                    ? (img is String && !img.startsWith('http')
                        ? 'https://$img'
                        : img)
                    : null;

            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EpisodeHeader(episode: episode, imageUrl: imageUrl),
                EpisodeDetails(episode: episode),
                Consumer(
                  builder: (context, ref, _) {
                    return EpisodeActions(
                      episode: episode,
                      showData: widget.showData,
                      seasonNumber: widget.seasonNumber,
                      episodeNumber: widget.episodeNumber,
                      currentRating: episodeRating,
                      onRatingChanged: _handleRatingUpdate,
                      onWatchedStatusChanged:
                          (isWatched) => _handleWatchedStatusChanged(
                            context,
                            ref,
                            episode,
                            isWatched,
                          ),
                      onCommentsPressed: _toggleComments,
                    );
                  },
                ),
                if (_showComments) ...[
                  const SizedBox(height: 16),
                  EpisodeComments(
                    showId: widget.showData['ids']['trakt'],
                    seasonNumber: widget.seasonNumber,
                    episodeNumber: widget.episodeNumber,
                  ),
                ],
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
