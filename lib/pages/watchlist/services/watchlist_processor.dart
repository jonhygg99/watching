import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/providers/app_providers.dart';

class WatchlistProcessor {
  final Ref _ref;
  final WatchlistEpisodeService _episodeService;
  final _translationCache = <String, Map<String, dynamic>>{};

  WatchlistProcessor(this._ref, [WatchlistEpisodeService? episodeService])
    : _episodeService = episodeService ?? WatchlistEpisodeService(_ref);

  /// Process a single watchlist item with timeout and error handling
  Future<Map<String, dynamic>?> processItem(
    Map<String, dynamic> item,
    dynamic trakt, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final show = item['show'] ?? item;
      final ids = show['ids'] ?? {};
      final traktId = ids['slug']?.toString() ?? ids['trakt']?.toString();

      if (traktId == null || traktId.isEmpty) {
        debugPrint('Skipping item with invalid traktId');
        return null;
      }

      // Initialize with minimal data structure
      if (show['title'] == null) {
        show['title'] = 'Loading...';
      }

      // Get the user's country code
      final countryCode = _ref.read(countryCodeProvider);

      // Get progress first
      final progress = await _withTimeout(
        () => trakt.getShowWatchedProgress(id: traktId),
        timeout: timeout,
        fallback: <String, dynamic>{},
      );

      // Get next episode and translations in parallel
      final results = await Future.wait<dynamic>([
        _withTimeout(
          () => _episodeService.getNextEpisode(trakt, traktId, progress),
          timeout: timeout,
          fallback: null,
        ),
        _withTimeout(
          () => _applyTranslations(trakt, traktId, show, countryCode),
          timeout: timeout,
          fallback: null,
        ),
      ], eagerError: true).catchError((e) {
        debugPrint('Error in parallel processing: $e');
        return [null, null];
      });

      final nextEpisode = results[0] as Map<String, dynamic>?;

      // Update progress with next episode if available
      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Create the final updated item
      final updatedItem = {
        ...item,
        'show': {
          ...show,
          'title': show['title'] ?? 'Unknown Title',
          'progress': progress,
        },
        'progress': progress,
      };

      // Ensure title is set at root level for backward compatibility
      updatedItem['title'] = show['title'] ?? 'Unknown Title';

      return updatedItem;
    } catch (e) {
      debugPrint('Error processing watchlist item: $e');
      // Return minimal valid item with error state
      return {...item, 'progress': {}, 'error': e.toString()};
    }
  }

  /// Helper method to add timeout to futures
  Future<T> _withTimeout<T>(
    Future<T> Function() future, {
    required Duration timeout,
    required T fallback,
  }) async {
    try {
      return await future().timeout(timeout);
    } catch (e) {
      debugPrint('Operation timed out or failed: $e');
      return fallback;
    }
  }

  /// Process multiple watchlist items with concurrency control
  Future<List<Map<String, dynamic>>> processItems(
    List<dynamic> items,
    dynamic trakt, {
    int maxConcurrent = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final filteredItems = items.whereType<Map<String, dynamic>>().toList();
    final results = <Map<String, dynamic>>[];

    // Process items in batches to control concurrency
    for (var i = 0; i < filteredItems.length; i += maxConcurrent) {
      final batch = filteredItems.sublist(
        i,
        i + maxConcurrent > filteredItems.length
            ? filteredItems.length
            : i + maxConcurrent,
      );

      final batchResults = await Future.wait(
        batch.map((item) => processItem(item, trakt, timeout: timeout)),
        eagerError: true,
      ).catchError((e) {
        debugPrint('Error in batch processing: $e');
        return <Map<String, dynamic>?>[];
      });

      results.addAll(batchResults.whereType<Map<String, dynamic>>());
    }

    return results;
  }

  /// Apply translations to a show with caching and fallback
  Future<void> _applyTranslations(
    dynamic trakt,
    String traktId,
    Map<String, dynamic> show,
    String countryCode,
  ) async {
    if (countryCode.isEmpty) return;

    final cacheKey = '${traktId}_${countryCode.toLowerCase()}';

    // Check cache first
    if (_translationCache.containsKey(cacheKey)) {
      _updateShowWithTranslation(show, _translationCache[cacheKey]!);
      return;
    }

    try {
      final result = await trakt.getShowTranslations(
        id: traktId,
        language: countryCode.toLowerCase(),
      );

      if (result != null) {
        // Ensure we have a List<Map> before proceeding
        List<Map<String, dynamic>> translations;
        if (result is List) {
          translations = result.cast<Map<String, dynamic>>();
        } else if (result is Map) {
          translations = [result.cast<String, dynamic>()];
        } else {
          debugPrint('Unexpected translations type: ${result.runtimeType}');
          return;
        }

        final translation = _findBestTranslation(translations, countryCode);
        if (translation != null) {
          // Update cache
          _translationCache[cacheKey] = translation;
          _updateShowWithTranslation(show, translation);
        }
      }
    } catch (e) {
      debugPrint('Error applying translations for $traktId: $e');
    }
  }

  /// Find the best matching translation from available translations
  /// Matches the behavior of ShowDetailPage
  Map<String, dynamic>? _findBestTranslation(
    dynamic translations,
    String countryCode,
  ) {
    try {
      // If translations is null, return early
      if (translations == null) return null;

      // If translations is a Function, call it to get the actual value
      if (translations is Function()) {
        try {
          final result = translations();
          // If the result is a Future, return null as we can't handle it here
          if (result is Future) return null;
          translations = result;
        } catch (e) {
          return null;
        }
      }

      // If translations is a Future, return null as we can't handle it here
      if (translations is Future) return null;

      // Convert to list if it's not already
      List<dynamic> translationsList;
      if (translations is List) {
        translationsList = translations;
      } else if (translations is Map) {
        translationsList = [translations];
      } else {
        return null;
      }

      if (translationsList.isEmpty) return null;

      // Filter out translations with null titles (same as show details)
      final validTranslations =
          translationsList
              .where((t) => t != null && t is Map && t['title'] != null)
              .toList();

      if (validTranslations.isEmpty) return null;

      final countryPrefix = countryCode.toLowerCase().substring(0, 2);

      // Try exact match for user's country (same as show details)
      try {
        return validTranslations.firstWhere(
              (t) => t['language']?.toString().toLowerCase() == countryPrefix,
              orElse: () => validTranslations.first as Map<String, dynamic>,
            )
            as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error finding best translation: $e');
      return null;
    }
  }

  /// Update show data with translation
  /// Matches the behavior of ShowDetailPage
  void _updateShowWithTranslation(
    Map<String, dynamic> show,
    Map<String, dynamic> translation,
  ) {
    try {
      // Update title if available in translation
      if (translation['title'] != null) {
        show['title'] = translation['title'];
      }

      // Update overview if available in translation
      if (translation['overview'] != null) {
        show['overview'] = translation['overview'];
      }

      // Update tagline if available in translation (matching show details behavior)
      if (translation['tagline'] != null) {
        show['tagline'] = translation['tagline'];
      }
    } catch (e) {
      debugPrint('Error updating show with translation: $e');
    }
  }
}
