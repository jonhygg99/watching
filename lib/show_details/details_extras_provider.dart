import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_providers.dart';
import 'details_extras.dart';

/// Provider to fetch videos, people, and related shows for a show in a single call.
final showDetailsExtrasProvider = FutureProvider.family<ShowDetailsExtras, String>((ref, showId) async {
  final api = ref.watch(apiServiceProvider);
  final results = await Future.wait([
    api.getShowVideos(id: showId),
    api.getShowPeople(id: showId),
    api.getRelatedShows(id: showId),
  ]);
  return ShowDetailsExtras(
    videos: results[0] as List<dynamic>,
    people: results[1] as Map<String, dynamic>?,
    relatedShows: results[2] as List<dynamic>,
  );
});
