import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/trakt/trakt_api.dart';

import '../watchlist/episode_info_modal.dart';
import '../watchlist/progress_bar.dart';

/// Page to display details and episodes of a season, with actions to mark all or individual episodes as watched.
class SeasonDetailPage extends HookConsumerWidget {
  final String showId;
  final int seasonNumber;
  final String? showTitle;
  final String? languageCode;
  const SeasonDetailPage({
    super.key,
    required this.showId,
    required this.seasonNumber,
    this.showTitle,
    this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traktApi = TraktApi();
    final loading = useState<bool>(true);
    final episodes = useState<List<dynamic>>([]);
    final progress = useState<Map<String, dynamic>?>(null);
    final markingColors = useState<Map<int, Color>>({});

    /// Fetch episodes and progress for the season
    useEffect(() {
      Future<void> fetchData() async {
        loading.value = true;
        try {
          final eps = await traktApi.getSeasonEpisodes(
            id: showId,
            season: seasonNumber,
            translations: languageCode,
          );
          final prog = await traktApi.getShowWatchedProgress(id: showId);
          episodes.value = eps;
          progress.value = prog;
        } finally {
          loading.value = false;
        }
      }
      fetchData();
      return null;
    }, [showId, seasonNumber, languageCode]);

    // Helper for marking color feedback
    Future<void> setMarkingColor(int epNumber, Color color, {int delayMs = 0}) async {
      markingColors.value = {
        ...markingColors.value,
        epNumber: color,
      };
      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // Mark all episodes as watched
    Future<void> markAllAsWatched() async {
      final episodeNumbers = episodes.value.map((e) => e['number'] as int).toList();
      for (final ep in episodeNumbers) {
        await setMarkingColor(ep, Colors.blue);
      }
      try {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids": int.tryParse(showId) != null
                  ? {"trakt": int.parse(showId)}
                  : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": episodeNumbers.map((n) => {"number": n}).toList(),
                },
              ],
            },
          ],
        );
        final eps = await traktApi.getSeasonEpisodes(
          id: showId,
          season: seasonNumber,
          translations: languageCode,
        );
        final prog = await traktApi.getShowWatchedProgress(id: showId);
        episodes.value = eps;
        progress.value = prog;
        for (final ep in episodeNumbers) {
          await setMarkingColor(ep, Colors.green, delayMs: 200);
          await setMarkingColor(ep, Colors.green);
        }
      } catch (e) {
        for (final ep in episodeNumbers) {
          await setMarkingColor(ep, Colors.red, delayMs: 500);
          await setMarkingColor(ep, Colors.grey);
        }
      }
    }

    // Mark single episode as watched
    Future<void> markEpisodeAsWatched(int epNumber) async {
      await setMarkingColor(epNumber, Colors.blue);
      try {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids": int.tryParse(showId) != null
                  ? {"trakt": int.parse(showId)}
                  : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": [
                    {"number": epNumber},
                  ],
                },
              ],
            },
          ],
        );
        final eps = await traktApi.getSeasonEpisodes(
          id: showId,
          season: seasonNumber,
          translations: languageCode,
        );
        final prog = await traktApi.getShowWatchedProgress(id: showId);
        episodes.value = eps;
        progress.value = prog;
        await setMarkingColor(epNumber, Colors.green, delayMs: 400);
        await setMarkingColor(epNumber, Colors.green);
      } catch (e) {
        await setMarkingColor(epNumber, Colors.red, delayMs: 500);
        await setMarkingColor(epNumber, Colors.grey);
      }
    }

    // Compute progress for this season
    double getSeasonProgress() {
      if (progress.value == null) return 0.0;
      final seasons = progress.value!["seasons"] as List?;
      final season = seasons?.firstWhere(
        (s) => s["number"] == seasonNumber,
        orElse: () => null,
      );
      if (season == null) return 0.0;
      final completed = season["completed"] ?? 0;
      final aired = season["aired"] ?? 1;
      return (completed / aired).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Temporada $seasonNumber'),
        actions: [
          Builder(
            builder: (context) {
              // Determine if all episodes are watched
              final episodeNumbers = episodes.value.map((e) => e['number'] as int).toList();
              bool allWatched = false;
              if (progress.value != null && episodeNumbers.isNotEmpty) {
                final seasons = progress.value!["seasons"] as List?;
                final season = seasons?.firstWhere(
                  (s) => s["number"] == seasonNumber,
                  orElse: () => null,
                );
                if (season != null && season["episodes"] is List) {
                  final watchedNumbers = (season["episodes"] as List)
                    .where((e) {
                      final completed = e["completed"];
                      if (completed is int) return completed > 0;
                      if (completed is bool) return completed;
                      return false;
                    })
                    .map((e) => e["number"] as int)
                    .toSet();
                  allWatched = watchedNumbers.length == episodeNumbers.length && episodeNumbers.isNotEmpty;
                }
              }
              return IconButton(
                icon: Icon(
                  Icons.done_all,
                  color: allWatched ? Colors.green : Colors.grey,
                ),
                tooltip: allWatched ? 'Eliminar temporada del historial' : 'Marcar todos como vistos',
                onPressed: loading.value
                    ? null
                    : () async {
                        // Set all to blue while processing
                        for (final ep in episodeNumbers) {
                          await setMarkingColor(ep, Colors.blue);
                        }
                        try {
                          if (allWatched) {
                            // Remove all episodes for this season from history
                            await traktApi.removeFromHistory(
                              shows: [
                                {
                                  "ids": int.tryParse(showId) != null
                                      ? {"trakt": int.parse(showId)}
                                      : {"slug": showId},
                                  "seasons": [
                                    {
                                      "number": seasonNumber,
                                      "episodes": episodeNumbers.map((n) => {"number": n}).toList(),
                                    },
                                  ],
                                },
                              ],
                            );
                          } else {
                            // Mark all episodes as watched
                            await traktApi.addToWatchHistory(
                              shows: [
                                {
                                  "ids": int.tryParse(showId) != null
                                      ? {"trakt": int.parse(showId)}
                                      : {"slug": showId},
                                  "seasons": [
                                    {
                                      "number": seasonNumber,
                                      "episodes": episodeNumbers.map((n) => {"number": n}).toList(),
                                    },
                                  ],
                                },
                              ],
                            );
                          }
                          final eps = await traktApi.getSeasonEpisodes(
                            id: showId,
                            season: seasonNumber,
                            translations: languageCode,
                          );
                          final prog = await traktApi.getShowWatchedProgress(id: showId);
                          episodes.value = eps;
                          progress.value = prog;
                          // After bulk action, set color for each episode according to watched state
                          final seasons = prog["seasons"] as List?;
                          final season = seasons?.firstWhere(
                            (s) => s["number"] == seasonNumber,
                            orElse: () => null,
                          );
                          final watchedNumbers = <int>{};
                          if (season != null && season["episodes"] is List) {
                            for (final e in (season["episodes"] as List)) {
                              final completed = e["completed"];
                              if ((completed is int && completed > 0) || completed == true) {
                                watchedNumbers.add(e["number"] as int);
                              }
                            }
                          }
                          for (final ep in episodeNumbers) {
                            if (watchedNumbers.contains(ep)) {
                              await setMarkingColor(ep, Colors.green);
                            } else {
                              await setMarkingColor(ep, Colors.grey);
                            }
                          }
                        } catch (e) {
                          for (final ep in episodeNumbers) {
                            await setMarkingColor(ep, Colors.red, delayMs: 500);
                            await setMarkingColor(ep, Colors.grey);
                          }
                        }
                    },
              );
            },
          ),
        ],
      ),
      body: loading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ProgressBar(
                    percent: getSeasonProgress(),
                    watched: (progress.value != null)
                        ? (progress.value!["seasons"] as List)
                              .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {})
                              .putIfAbsent("completed", () => 0)
                        : 0,
                    total: (progress.value != null)
                        ? (progress.value!["seasons"] as List)
                              .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {})
                              .putIfAbsent("aired", () => 1)
                        : 1,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: episodes.value.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final ep = episodes.value[idx];
                      final epNumber = ep['number'] as int;
                      final epTitle = ep['title'] ?? '';
                      // Robust check for watched status (handles int/bool/null)
                      /// Helper to determine if an episode is watched (Trakt returns int or bool)
                      bool isEpisodeWatched(dynamic e) {
                        final completed = e["completed"];
                        if (completed is int) return completed > 0;
                        if (completed is bool) return completed;
                        return false;
                      }
                      /// Returns true if this episode is watched according to progress
                      bool epWatched() {
                        final seasons = progress.value?["seasons"] as List?;
                        final season = seasons?.firstWhere(
                          (s) => s["number"] == seasonNumber,
                          orElse: () => null,
                        );
                        if (season == null || season["episodes"] is! List) return false;
                        return (season["episodes"] as List)
                          .any((e) => e["number"] == epNumber && isEpisodeWatched(e));
                      }
                      final watched = epWatched();
                      return ListTile(
                        leading: CircleAvatar(child: Text('$epNumber')),
                        title: Text(epTitle),
                        // Single check icon, green if watched, grey if not
                        trailing: IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: watched
                                ? (markingColors.value[epNumber] ?? Colors.green)
                                : (markingColors.value[epNumber] ?? Colors.grey),
                          ),
                          tooltip: watched ? 'Eliminar episodio del historial' : 'Marcar como visto',
                          onPressed: loading.value
                              ? null
                              : () async {
                                  await setMarkingColor(epNumber, Colors.blue);
                                  try {
                                    if (watched) {
                                      // Unchecking: remove from history
                                      await traktApi.removeFromHistory(
                                        shows: [
                                          {
                                            "ids": int.tryParse(showId) != null
                                                ? {"trakt": int.parse(showId)}
                                                : {"slug": showId},
                                            "seasons": [
                                              {
                                                "number": seasonNumber,
                                                "episodes": [
                                                  {"number": epNumber},
                                                ],
                                              },
                                            ],
                                          },
                                        ],
                                      );
                                    } else {
                                      // Checking: add to history
                                      await traktApi.addToWatchHistory(
                                        shows: [
                                          {
                                            "ids": int.tryParse(showId) != null
                                                ? {"trakt": int.parse(showId)}
                                                : {"slug": showId},
                                            "seasons": [
                                              {
                                                "number": seasonNumber,
                                                "episodes": [
                                                  {"number": epNumber},
                                                ],
                                              },
                                            ],
                                          },
                                        ],
                                      );
                                    }
                                    final eps = await traktApi.getSeasonEpisodes(
                                      id: showId,
                                      season: seasonNumber,
                                      translations: languageCode,
                                    );
                                    final prog = await traktApi.getShowWatchedProgress(id: showId);
                                    episodes.value = eps;
                                    progress.value = prog;
                                    // Determine watched state after API
                                    final isNowWatched = (() {
                                      final seasons = prog["seasons"] as List?;
                                      final season = seasons?.firstWhere(
                                        (s) => s["number"] == seasonNumber,
                                        orElse: () => null,
                                      );
                                      if (season == null || season["episodes"] is! List) return false;
                                      return (season["episodes"] as List)
                                        .any((e) => e["number"] == epNumber && (e["completed"] == true || (e["completed"] is int && e["completed"] > 0)));
                                    })();
                                    if (isNowWatched) {
                                      // If watched, keep green
                                      await setMarkingColor(epNumber, Colors.green);
                                    } else {
                                      // If not watched, set to grey
                                      await setMarkingColor(epNumber, Colors.grey);
                                    }
                                  } catch (e) {
                                    await setMarkingColor(epNumber, Colors.red, delayMs: 500);
                                    await setMarkingColor(epNumber, Colors.grey);
                                  }
                                },
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (ctx) => EpisodeInfoModal(
                              episodeFuture: traktApi.getEpisodeInfo(
                                id: showId,
                                season: seasonNumber,
                                episode: epNumber,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
