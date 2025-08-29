import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api_provider.dart';
import 'package:watching/shared/pages/show_details/pages/seasons/models/episode_state.dart';

part 'season_detail_provider.g.dart';

typedef SeasonDetails = ({
  List<Map<String, dynamic>> episodes,
  Map<String, dynamic> progress,
  Map<int, EpisodeState> episodeStates,
});

class _PendingUpdate {
  final int episodeNumber;
  final bool watched;
  final Completer<void> completer;
  
  _PendingUpdate({
    required this.episodeNumber,
    required this.watched,
    required this.completer,
  });
}

// Using AutoDisposeAsyncNotifierProvider to automatically clean up resources
@riverpod
class SeasonDetail extends _$SeasonDetail {
  Timer? _batchTimer;
  final List<_PendingUpdate> _pendingUpdates = [];
  final Map<int, EpisodeState> _episodeStates = {};
  @override
  Future<SeasonDetails> build({
    required String showId,
    required int seasonNumber,
    String? languageCode,
  }) async {
    final traktApi = ref.watch(traktApiProvider);

    final results = await Future.wait([
      traktApi.getSeasonEpisodes(
        id: showId,
        season: seasonNumber,
        translations: languageCode,
      ),
      traktApi.getShowWatchedProgress(id: showId),
    ]);

    final episodes = List<Map<String, dynamic>>.from(results[0] as List);
    final progress = Map<String, dynamic>.from(results[1] as Map);

    return (
      episodes: episodes, 
      progress: progress,
      episodeStates: _episodeStates,
    );
  }

  // Clean up resources when the provider is no longer needed
  void _cleanup() {
    // Cancel any pending batch timer
    _batchTimer?.cancel();
    _batchTimer = null;
    
    // Complete any pending updates with an error
    for (final update in _pendingUpdates) {
      if (!update.completer.isCompleted) {
        update.completer.completeError('Provider was disposed');
      }
    }
    _pendingUpdates.clear();
  }

  /// Updates the state of an episode and returns the current state
  EpisodeState _updateEpisodeState(int episodeNumber, EpisodeState newState) {
    _episodeStates[episodeNumber] = newState;
    ref.notifyListeners();
    return newState;
  }

  /// Flushes all pending updates in a single batch
  Future<void> _flushPendingUpdates() async {
    if (_pendingUpdates.isEmpty) return;

    final traktApi = ref.read(traktApiProvider);
    final showIdInt = int.parse(showId);
    
    // Group updates by watched status
    final episodesToAdd = <Map<String, dynamic>>[];
    final episodesToRemove = <Map<String, dynamic>>[];
    
    for (final update in _pendingUpdates) {
      final episodeData = {
        'show_id': showIdInt,
        'season': seasonNumber,
        'episode': update.episodeNumber,
      };
      
      if (update.watched) {
        episodesToAdd.add(episodeData);
      } else {
        episodesToRemove.add(episodeData);
      }
    }

    try {
      // Process all updates in a single batch API call
      await traktApi.batchUpdateEpisodeWatchStatus(
        episodesToAdd: episodesToAdd,
        episodesToRemove: episodesToRemove,
      );
      
      // Complete all completers
      for (final update in _pendingUpdates) {
        if (!update.completer.isCompleted) {
          update.completer.complete();
        }
      }
      
      // Update local states
      for (final update in _pendingUpdates) {
        _updateEpisodeState(
          update.episodeNumber,
          update.watched ? EpisodeState.watched : EpisodeState.unwatched,
        );
      }
    } catch (e) {
      // Complete all completers with error
      for (final update in _pendingUpdates) {
        if (!update.completer.isCompleted) {
          update.completer.completeError(e);
        }
      }
      rethrow;
    } finally {
      _pendingUpdates.clear();
      ref.invalidateSelf();
    }
  }

  /// Gets the current state of an episode
  EpisodeState getEpisodeState(int episodeNumber) {
    return _episodeStates[episodeNumber] ?? EpisodeState.unwatched;
  }

  /// Toggles the watched status of an episode with batching
  Future<void> toggleEpisodeWatched(int episodeNumber, bool watched) async {
    try {
      // Update local state immediately for responsive UI
      _updateEpisodeState(episodeNumber, EpisodeState.processing);
      
      final completer = Completer<void>();
      _pendingUpdates.add(_PendingUpdate(
        episodeNumber: episodeNumber,
        watched: watched,
        completer: completer,
      ));
      
      // Start or reset the batch timer
      _batchTimer?.cancel();
      _batchTimer = Timer(const Duration(seconds: 1), () {
        if (!completer.isCompleted) {
          _flushPendingUpdates();
        }
      });
      
      return completer.future;
    } catch (e) {
      // Clean up and rethrow
      _cleanup();
      rethrow;
    }
  }

  /// Toggles watched status for all episodes in the season
  /// [markAsWatched] - if true, marks all episodes as watched, if false, marks all as unwatched
  Future<void> toggleSeasonWatched(bool markAsWatched) async {
    try {
      final state = this.state;
      if (state.isLoading || state.hasError) return;
      
      final episodes = state.value!.episodes;
      final episodesToAdd = <Map<String, dynamic>>[];
      final episodesToRemove = <Map<String, dynamic>>[];
      final showIdInt = int.parse(showId);
      
      // Update all episodes based on the markAsWatched flag
      for (final episode in episodes) {
        final epNumber = episode['number'] as int;
        
        final episodeData = {
          'show_id': showIdInt,
          'season': seasonNumber,
          'episode': epNumber,
        };
        
        if (markAsWatched) {
          episodesToAdd.add(episodeData);
        } else {
          episodesToRemove.add(episodeData);
        }
      }
      
      // Update local state immediately for responsive UI
      for (final episode in episodes) {
        final epNumber = episode['number'] as int;
        _updateEpisodeState(epNumber, EpisodeState.processing);
      }
      
      // Process all updates in a single batch API call
      final traktApi = ref.read(traktApiProvider);
      await traktApi.batchUpdateEpisodeWatchStatus(
        episodesToAdd: markAsWatched ? episodesToAdd : [],
        episodesToRemove: markAsWatched ? [] : episodesToRemove,
      );
      
      // Update local states to final values
      for (final episode in episodes) {
        final epNumber = episode['number'] as int;
        _updateEpisodeState(
          epNumber,
          markAsWatched ? EpisodeState.watched : EpisodeState.unwatched,
        );
      }
      
      // Invalidate to refresh the UI
      ref.invalidateSelf();
      
    } catch (e) {
      // Clean up and rethrow
      _cleanup();
      rethrow;
    }
  }
}
