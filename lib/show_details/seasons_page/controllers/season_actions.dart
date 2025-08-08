/// Controlador de acciones bulk y toggle para episodios de temporada.
import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

/// Manages batching of episode actions to handle API rate limits
class _BatchEpisodeAction {
  final TraktApi traktApi;
  final String showId;
  final String? languageCode;
  
  Timer? _batchTimer;
  final Map<int, Set<int>> _episodesToAdd = {}; // season -> episode numbers to add
  final Map<int, Set<int>> _episodesToRemove = {}; // season -> episode numbers to remove
  final Set<void Function()> _refreshCallbacks = {};
  
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
    final seasonEpisodes = _episodesToAdd[season];
    if (seasonEpisodes == null || !seasonEpisodes.contains(episode)) {
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
    final seasonEpisodes = _episodesToRemove[season];
    if (seasonEpisodes == null || !seasonEpisodes.contains(episode)) {
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
    _batchTimer = Timer(const Duration(seconds: 1), _processBatch);
  }
  
  Future<void> _processBatch() async {
    if (_episodesToAdd.isEmpty && _episodesToRemove.isEmpty) return;
    
    // Save current batches to process
    final episodesToAdd = Map<int, Set<int>>.from(_episodesToAdd);
    final episodesToRemove = Map<int, Set<int>>.from(_episodesToRemove);
    final callbacks = List<void Function()>.from(_refreshCallbacks);
    
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
      
      // If rate limit was hit, requeue the operations with a delay
      if (shouldRetry) {
        await Future.delayed(const Duration(seconds: 2));
        
        // Re-add the operations to the appropriate batches
        episodesToAdd.forEach((season, episodes) {
          for (final ep in episodes) {
            addEpisode(season, ep, callbacks.removeLast());
          }
        });
        
        episodesToRemove.forEach((season, episodes) {
          for (final ep in episodes) {
            removeEpisode(season, ep, callbacks.removeLast());
          }
        });
        
        return; // Exit and let the timer handle the retry
      }
      
      // If we get here, all operations were successful
      for (final callback in callbacks) {
        try {
          callback();
          // Small delay between callbacks to prevent UI jank
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          debugPrint('Error in batch callback: $e');
        }
      }
    } catch (e) {
      // If any other error occurs, make sure to update the UI state
      for (final callback in callbacks) {
        try {
          callback();
          // Small delay between callbacks to prevent UI jank
          await Future.delayed(const Duration(milliseconds: 50));
        } catch (e) {
          debugPrint('Error in batch error callback: $e');
        }
      }
      rethrow;
    }
  }
  
  Map<String, dynamic> _buildShowsPayload(Map<int, Set<int>> episodesBySeason) {
    return {
      'ids': int.tryParse(showId) != null 
          ? {'trakt': int.parse(showId)}
          : {'slug': showId},
      'seasons': episodesBySeason.entries.map((entry) {
        return {
          'number': entry.key,
          'episodes': entry.value.map((ep) => {'number': ep}).toList(),
        };
      }).toList(),
    };
  }
  
  void dispose() {
    _batchTimer?.cancel();
    _episodesToAdd.clear();
    _episodesToRemove.clear();
    _refreshCallbacks.clear();
  }
}

// Global instance for the batch action
final _batchAction = <String, _BatchEpisodeAction>{};

class SeasonActions {
  // Instance of the batch action for each show
  static _BatchEpisodeAction _getBatchAction({
    required String showId,
    required TraktApi traktApi,
    required String? languageCode,
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
  /// Acción bulk: marcar o desmarcar todos los episodios de la temporada.
  static Future<void> handleBulkAction({
    required bool allWatched,
    required List<Map<String, dynamic>> episodes,
    required int seasonNumber,
    required String showId,
    required String? languageCode,
    required TraktApi traktApi,
    required Future<void> Function(int, Color, {int delayMs}) setMarkingColor,
    required ValueNotifier<List<Map<String, dynamic>>> episodesState,
    required ValueNotifier<Map<String, dynamic>?> progressState,
  }) async {
    for (final ep in episodes.map((e) => e['number'] as int)) {
      await setMarkingColor(ep, Colors.blue);
    }
    try {
      if (allWatched) {
        await traktApi.removeFromHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes":
                      episodes.map((n) => {"number": n['number']}).toList(),
                },
              ],
            },
          ],
        );
      } else {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes":
                      episodes.map((n) => {"number": n['number']}).toList(),
                },
              ],
            },
          ],
        );
      }
      final List<Map<String, dynamic>> eps = List<Map<String, dynamic>>.from(
        await traktApi.getSeasonEpisodes(
          id: showId,
          season: seasonNumber,
          translations: languageCode,
        ),
      );
      final Map<String, dynamic> prog = Map<String, dynamic>.from(
        await traktApi.getShowWatchedProgress(id: showId),
      );
      episodesState.value = eps;
      progressState.value = prog;
      final List<dynamic>? seasons = prog["seasons"] as List<dynamic>?;
      final Map<String, dynamic>? season = seasons
          ?.cast<Map<String, dynamic>>()
          .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
      final Set<int> watchedNumbers = <int>{};
      if (season != null && season["episodes"] is List) {
        for (final e in (season["episodes"] as List)) {
          final completed = e["completed"];
          if ((completed is int && completed > 0) || completed == true) {
            watchedNumbers.add(e["number"] as int);
          }
        }
      }
      for (final ep in episodes.map((e) => e['number'] as int)) {
        if (watchedNumbers.contains(ep)) {
          await setMarkingColor(ep, Colors.green);
        } else {
          await setMarkingColor(ep, Colors.grey);
        }
      }
    } catch (e) {
      for (final ep in episodes.map((e) => e['number'] as int)) {
        await setMarkingColor(ep, Colors.red, delayMs: 500);
        await setMarkingColor(ep, Colors.grey);
      }
    }
  }

  /// Acción de marcar/desmarcar un episodio individual.
  static Future<void> handleToggleEpisode({
    required String showId,
    required int seasonNumber,
    required int epNumber,
    required bool watched,
    required TraktApi traktApi,
    required Future<void> Function(int, Color, {int delayMs}) setMarkingColor,
    required ValueNotifier<List<Map<String, dynamic>>> episodesState,
    required ValueNotifier<Map<String, dynamic>?> progressState,
    String? languageCode,
    VoidCallback? onEpisodeToggled,
  }) async {
    // Save the current state before making changes
    final previousEpisodesState = List<Map<String, dynamic>>.from(episodesState.value);
    final previousProgressState = progressState.value != null 
        ? Map<String, dynamic>.from(progressState.value!) 
        : null;
    
    // Update UI optimistically
    await setMarkingColor(epNumber, Colors.blue);
    
    try {
      // Get or create batch action for this show
      final batchAction = _getBatchAction(
        showId: showId,
        traktApi: traktApi,
        languageCode: languageCode,
      );
      
      // Create a callback to refresh the data after batch operation
      final refreshData = () async {
        // First, set a temporary state to indicate loading
        await setMarkingColor(epNumber, Colors.blue);
        
        try {
          // Refresh the data after batch operation completes
          final eps = await traktApi.getSeasonEpisodes(
            id: showId,
            season: seasonNumber,
            translations: languageCode,
          );
          final prog = await traktApi.getShowWatchedProgress(id: showId);
          
          // Update state
          episodesState.value = List<Map<String, dynamic>>.from(eps);
          progressState.value = Map<String, dynamic>.from(prog);
          
          // Update marking color based on new state
          final isWatched = _isEpisodeWatched(prog, seasonNumber, epNumber);
          await setMarkingColor(
            epNumber,
            isWatched ? Colors.green : Colors.grey,
          );
          
          // Notify that an episode was toggled
          onEpisodeToggled?.call();
        } catch (e) {
          debugPrint('Error refreshing episode state: $e');
          
          // On error, try to get the latest state from the server
          try {
            final prog = await traktApi.getShowWatchedProgress(id: showId);
            final isWatched = _isEpisodeWatched(prog, seasonNumber, epNumber);
            await setMarkingColor(
              epNumber,
              isWatched ? Colors.green : Colors.grey,
            );
            progressState.value = Map<String, dynamic>.from(prog);
          } catch (e2) {
            debugPrint('Failed to recover state: $e2');
            // If we can't get the latest state, revert to previous known state
            episodesState.value = previousEpisodesState;
            progressState.value = previousProgressState;
            
            // Show error feedback
            await setMarkingColor(epNumber, Colors.red, delayMs: 500);
            
            // Revert to the correct state based on the previous known status
            final isCurrentlyWatched = _isEpisodeWatched(
              previousProgressState ?? <String, dynamic>{},
              seasonNumber, 
              epNumber,
            );
            await setMarkingColor(
              epNumber,
              isCurrentlyWatched ? Colors.green : Colors.grey,
            );
          }
        }
      };
      
      // Add to appropriate batch
      if (watched) {
        batchAction.addEpisode(seasonNumber, epNumber, refreshData);
      } else {
        batchAction.removeEpisode(seasonNumber, epNumber, refreshData);
      }
    } catch (e) {
      // Revert to previous state on error
      episodesState.value = previousEpisodesState;
      progressState.value = previousProgressState;
      
      // Show error feedback
      await setMarkingColor(epNumber, Colors.red, delayMs: 500);
      
      // Revert to the correct state based on the actual watched status
      final isCurrentlyWatched = _isEpisodeWatched(
        previousProgressState ?? <String, dynamic>{},
        seasonNumber, 
        epNumber,
      );
      await setMarkingColor(
        epNumber,
        isCurrentlyWatched ? Colors.green : Colors.grey,
      );
      
      // Notify about the error state
      onEpisodeToggled?.call();
      rethrow;
    }
  }

  static bool _isEpisodeWatched(Map<String, dynamic> progress, int seasonNumber, int epNumber) {
    final seasons = progress['seasons'] as List?;
    if (seasons == null) return false;
    
    for (final season in seasons.cast<Map<String, dynamic>>()) {
      if (season['number'] == seasonNumber) {
        final episodes = season['episodes'] as List?;
        if (episodes == null) return false;
        
        for (final ep in episodes.cast<Map<String, dynamic>>()) {
          if (ep['number'] == epNumber) {
            final completed = ep['completed'];
            return (completed is int && completed > 0) || completed == true;
          }
        }
      }
    }
    return false;
  }
}
