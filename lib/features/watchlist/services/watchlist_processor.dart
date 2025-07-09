import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/providers/app_providers.dart';

class WatchlistProcessor {
  final Ref _ref;
  late final WatchlistEpisodeService _episodeService;

  WatchlistProcessor(this._ref) {
    _episodeService = WatchlistEpisodeService(_ref);
  }

  /// Process a single watchlist item
  Future<Map<String, dynamic>?> processItem(
    Map<String, dynamic> item,
    dynamic trakt,
  ) async {
    try {
      final show = item['show'] ?? item;
      final ids = show['ids'];
      final traktId = ids?['slug'] ?? ids?['trakt']?.toString();

      if (traktId == null) return null;

      // Get the user's country code
      final countryCode = _ref.read(countryCodeProvider);
      
      // Fetch progress and next episode in parallel
      final progress = await trakt.getShowWatchedProgress(id: traktId);
      final nextEpisode = await _episodeService.getNextEpisode(trakt, traktId, progress);

      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Create a new show map to avoid modifying the original
      final updatedShow = Map<String, dynamic>.from(show);
      
      // Handle translations
      await _applyTranslations(trakt, traktId, updatedShow, countryCode);

      // Create a new item with the updated show and progress
      final updatedItem = {
        ...item,
        'show': {
          ...updatedShow,
          // Ensure the title is set at the root level for backward compatibility
          'title': updatedShow['title'] ?? show['title']
        },
        'progress': progress,
      };
      
      // Also set the title at the root level for backward compatibility
      if (updatedShow['title'] != null) {
        updatedItem['title'] = updatedShow['title'];
      }
      
      return updatedItem;
    } catch (e) {
      debugPrint('Error processing watchlist item: $e');
      return {...item, 'progress': {}};
    }
  }

  /// Process multiple watchlist items
  Future<List<Map<String, dynamic>>> processItems(
    List<dynamic> items,
    dynamic trakt,
  ) async {
    final filteredItems = items.whereType<Map<String, dynamic>>().toList();

    final results = await Future.wait(
      filteredItems.map((item) => processItem(item, trakt)),
      eagerError: true,
    );

    return results.whereType<Map<String, dynamic>>().toList();
  }

  /// Apply translations to a show
  Future<void> _applyTranslations(
    dynamic trakt,
    String traktId,
    Map<String, dynamic> show,
    String countryCode,
  ) async {
    if (countryCode.isEmpty) return;

    try {
      final translations = await trakt.getShowTranslations(
        id: traktId,
        language: countryCode.toLowerCase(),
      );

      if (translations != null && translations.isNotEmpty) {
        // Filter out translations with null title and convert to List if needed
        List<dynamic> validTranslations = [];
        if (translations is List) {
          validTranslations = translations.where((t) => t['title'] != null).toList();
        } else if (translations is Map) {
          if (translations['title'] != null) {
            validTranslations = [translations];
          }
        }

        // Find the best matching translation
        Map<String, dynamic>? translation;
        if (validTranslations.isNotEmpty) {
          // Try to find exact match for user's country
          translation = validTranslations.firstWhere(
            (t) => t['language']?.toString().toLowerCase() == 
                  countryCode.toLowerCase().substring(0, 2),
            orElse: () => validTranslations.first,
          );

          // Update title and overview if translation found
          if (translation != null) {
            show['title'] = translation['title'] ?? show['title'];
            if (translation['overview'] != null) {
              show['overview'] = translation['overview'];
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error applying translations: $e');
    }
  }
}
