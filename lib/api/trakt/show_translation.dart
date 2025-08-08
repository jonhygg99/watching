import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

class ShowTranslationService {
  final Ref _ref;
  final _translationCache = <String, Map<String, dynamic>>{};

  ShowTranslationService(this._ref);

  /// Get the translated title for a show
  Future<String> getTranslatedTitle({
    required dynamic show,
    required dynamic traktApi,
  }) async {
    try {
      final ids = show['ids'] ?? {};
      final traktId = ids['slug']?.toString() ?? ids['trakt']?.toString();
      
      if (traktId == null) {
        return show['title'] ?? 'Untitled';
      }

      final countryCode = _ref.read(countryCodeProvider);
      if (countryCode.isEmpty) {
        return show['title'] ?? 'Untitled';
      }

      final cacheKey = '${traktId}_${countryCode.toLowerCase()}';
      
      // Check cache first
      if (_translationCache.containsKey(cacheKey)) {
        return _translationCache[cacheKey]?['title'] ?? show['title'] ?? 'Untitled';
      }

      // Fetch translation
      final result = await traktApi.getShowTranslations(
        id: traktId,
        language: countryCode.toLowerCase(),
      );

      if (result != null) {
        final translation = _findBestTranslation(result, countryCode);
        if (translation != null) {
          _translationCache[cacheKey] = translation;
          return translation['title'] ?? show['title'] ?? 'Untitled';
        }
      }
    } catch (e) {
      debugPrint('Error getting show translation: $e');
    }
    
    return show['title'] ?? 'Untitled';
  }

  /// Find the best matching translation from available translations
  Map<String, dynamic>? _findBestTranslation(
    dynamic translations,
    String countryCode,
  ) {
    try {
      if (translations == null) return null;
      
      List<dynamic> translationsList;
      if (translations is List) {
        translationsList = translations;
      } else if (translations is Map) {
        translationsList = [translations];
      } else {
        return null;
      }
      
      if (translationsList.isEmpty) return null;
      
      // Filter out translations with null titles
      final validTranslations = translationsList
          .where((t) => t != null && t is Map && t['title'] != null)
          .toList();
          
      if (validTranslations.isEmpty) return null;
      
      final countryPrefix = countryCode.toLowerCase().substring(0, 2);
      
      // Try exact match for user's country
      return validTranslations.firstWhere(
        (t) => t['language']?.toString().toLowerCase() == countryPrefix,
        orElse: () => validTranslations.first,
      );
    } catch (e) {
      debugPrint('Error finding best translation: $e');
      return null;
    }
  }
}

final showTranslationServiceProvider = Provider<ShowTranslationService>((ref) {
  return ShowTranslationService(ref);
});
