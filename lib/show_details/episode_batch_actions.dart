import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

/// Manages batching of episode actions to handle API rate limits for the details page
class _BatchEpisodeAction {
  final TraktApi traktApi;
  final String showId;
  final String? languageCode;

  Timer? _batchTimer;
  final Map<int, Set<int>> _episodesToAdd = {}; // season -> episode numbers to add
  final Map<int, Set<int>> _episodesToRemove = {}; // season -> episode numbers to remove
  final Set<VoidCallback> _refreshCallbacks = {};

  _BatchEpisodeAction({
    required this.traktApi,
    required this.showId,
    this.languageCode,
  });

  /// Add an episode to be marked as watched
  void addEpisode(int season, int episode, VoidCallback onComplete) {
    // Remove from opposite batch if it exists
    _episodesToRemove[season]?.remove(episode);

    // Add to add batch if not already there
    if (!_episodesToAdd.containsKey(season) || !_episodesToAdd[season]!.contains(episode)) {
      _episodesToAdd.putIfAbsent(season, () => <int>{}).add(episode);
      _refreshCallbacks.add(onComplete);
      _startBatchTimer();
    } else {
      // If already in add batch, just update the callback
      _refreshCallbacks.add(onComplete);
    }
  }

  /// Add an episode to be marked as unwatched
  void removeEpisode(int season, int episode, VoidCallback onComplete) {
    // Remove from opposite batch if it exists
    _episodesToAdd[season]?.remove(episode);

    // Add to remove batch if not already there
    if (!_episodesToRemove.containsKey(season) || !_episodesToRemove[season]!.contains(episode)) {
      _episodesToRemove.putIfAbsent(season, () => <int>{}).add(episode);
      _refreshCallbacks.add(onComplete);
      _startBatchTimer();
    } else {
      // If already in remove batch, just update the callback
      _refreshCallbacks.add(onComplete);
    }
  }

  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 500), _processBatch);
  }

  Future<void> _processBatch() async {
    if (_episodesToAdd.isEmpty && _episodesToRemove.isEmpty) return;

    // Save current batches to process
    final episodesToAdd = Map<int, Set<int>>.from(_episodesToAdd);
    final episodesToRemove = Map<int, Set<int>>.from(_episodesToRemove);
    final callbacks = List<VoidCallback>.from(_refreshCallbacks);

    // Clear current batches to allow new operations
    _episodesToAdd.clear();
    _episodesToRemove.clear();
    _refreshCallbacks.clear();

    bool shouldRetry = false;

    try {
      // Process additions if any
      if (episodesToAdd.isNotEmpty) {
        try {
          await traktApi.addToWatchHistory(
            shows: [_buildShowsPayload(episodesToAdd)],
          );
        } catch (e) {
          if (e.toString().contains('AUTHED_API_POST_LIMIT')) {
            shouldRetry = true;
          } else {
            rethrow;
          }
        }
      }

      // Process removals if any and no rate limit hit yet
      if (episodesToRemove.isNotEmpty && !shouldRetry) {
        try {
          await traktApi.removeFromHistory(
            shows: [_buildShowsPayload(episodesToRemove)],
          );
        } catch (e) {
          if (e.toString().contains('AUTHED_API_POST_LIMIT')) {
            shouldRetry = true;
          } else {
            rethrow;
          }
        }
      }

      // If rate limit was hit, requeue the batches for later processing
      if (shouldRetry) {
        _episodesToAdd.addAll(episodesToAdd);
        _episodesToRemove.addAll(episodesToRemove);
        _refreshCallbacks.addAll(callbacks);
        _startBatchTimer();
        return;
      }

      // Call all refresh callbacks
      for (final callback in callbacks) {
        try {
          callback();
        } catch (e) {
          // Ignore errors in callbacks
        }
      }
    } catch (e) {
      // On error, still call callbacks to update UI
      for (final callback in callbacks) {
        try {
          callback();
        } catch (_) {
          // Ignore errors in callbacks
        }
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildShowsPayload(Map<int, Set<int>> episodes) {
    return {
      'ids': int.tryParse(showId) != null
          ? {'trakt': int.parse(showId)}
          : {'slug': showId},
      'seasons': episodes.entries.map((entry) {
        return {
          'number': entry.key,
          'episodes': entry.value.map((ep) => {'number': ep}).toList(),
        };
      }).toList(),
    };
  }

  void dispose() {
    _batchTimer?.cancel();
  }
}

// Global instance for the batch action
final _batchAction = <String, _BatchEpisodeAction>{};

/// Handles batch operations for marking episodes as watched/unwatched
class EpisodeBatchActions {
  /// Get or create a batch action instance for a show
  static _BatchEpisodeAction _getBatchAction({
    required String showId,
    required TraktApi traktApi,
    String? languageCode,
  }) {
    return _batchAction.putIfAbsent(
      showId,
      () => _BatchEpisodeAction(
        traktApi: traktApi,
        showId: showId,
        languageCode: languageCode,
      ),
    );
  }

  /// Toggle an episode's watched state with batching
  static Future<void> toggleEpisode({
    required String showId,
    required int seasonNumber,
    required int episodeNumber,
    required bool watched,
    required TraktApi traktApi,
    required Future<void> Function() onComplete,
    String? languageCode,
  }) async {
    final batchAction = _getBatchAction(
      showId: showId,
      traktApi: traktApi,
      languageCode: languageCode,
    );

    if (watched) {
      batchAction.addEpisode(seasonNumber, episodeNumber, onComplete);
    } else {
      batchAction.removeEpisode(seasonNumber, episodeNumber, onComplete);
    }
  }

  /// Clean up batch action for a show
  static void dispose(String showId) {
    _batchAction[showId]?.dispose();
    _batchAction.remove(showId);
  }
}
