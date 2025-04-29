import 'package:flutter/material.dart';
import 'package:watching/api_service.dart';
import 'package:watching/watchlist/progress_bar.dart';
import 'package:watching/watchlist/episode_info_button.dart';
import 'package:watching/watchlist/show_card.dart';
import 'package:watching/watchlist/episode_info_modal.dart';
import 'package:watching/show_details/details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:io';

// Widget para mostrar el progreso y la info de cada serie
class _WatchProgressInfo extends StatefulWidget {
  final String? traktId;
  final String title;

  const _WatchProgressInfo({Key? key, required this.traktId, required this.title}) : super(key: key);

  @override
  State<_WatchProgressInfo> createState() => _WatchProgressInfoState();
}

class _WatchProgressInfoState extends State<_WatchProgressInfo> {
  Map<String, dynamic>? progress;
  bool loading = false;
  bool error = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.traktId == null) return;
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final prog = await apiService.getShowWatchedProgress(id: widget.traktId!);
      if (!mounted || _disposed) return;
      setState(() {
        progress = prog;
        loading = false;
      });
    } catch (e) {
      if (!mounted || _disposed) return;
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
    final TextStyle episodeStyle = Theme.of(context).textTheme.bodyMedium!;

    // Usa ProgressBar importado

    if (widget.traktId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
        ],
      );
    }
    if (loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 8),
        ],
      );
    }
    if (error || progress == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          const SizedBox(height: 8),
          Text('Error al cargar progreso', style: TextStyle(color: Colors.red)),
        ],
      );
    }
    final episodesWatched = progress!['completed'] ?? 0;
    final totalEpisodes = progress!['aired'] ?? 1;
    final nextEpisode = progress!['next_episode'];
    final percent = totalEpisodes > 0 ? (episodesWatched / totalEpisodes).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: titleStyle),
        if (nextEpisode != null) ...[
          const SizedBox(height: 6),
          Text(
            'T${nextEpisode['season']}E${nextEpisode['number']} - ${nextEpisode['title']}',
            style: episodeStyle.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          ProgressBar(percent: percent, watched: episodesWatched, total: totalEpisodes),
          const SizedBox(height: 6),
          EpisodeInfoButton(
            traktId: widget.traktId,
            season: nextEpisode['season'],
            episode: nextEpisode['number'],
            apiService: apiService,
          ),
        ],
      ],
    );
  }
}

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  String _type = 'shows';
  late Future<List<dynamic>> _futureWatchlist;

  @override
  void initState() {
    super.initState();
    _futureWatchlist = _getFilteredWatchlist();
  }

  Future<List<dynamic>> _getFilteredWatchlist() async {
    final items = await apiService.getWatched(type: _type);
    // Prepara todas las peticiones de progreso en paralelo
    final futures = items.map((item) async {
      final show = item['show'];
      final ids = show != null ? show['ids'] : null;
      final traktId = ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;
      if (traktId != null) {
        try {
          final progress = await apiService.getShowWatchedProgress(id: traktId);
          if (progress['next_episode'] != null) {
            return item;
          }
        } catch (e) {
          // Si hay error, puedes decidir mostrarlo o no
        }
        return null;
      } else {
        // Si no hay traktId, igual lo mostramos
        return item;
      }
    }).toList();
    final results = await Future.wait(futures);
    // Filtra los nulos (series completas)
    return results.where((item) => item != null).toList();
  }

  void _onTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _type = newType;
      _futureWatchlist = _getFilteredWatchlist();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'shows', child: Text('Shows')),
                  DropdownMenuItem(value: 'movies', child: Text('Movies')),
                ],
                onChanged: _onTypeChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureWatchlist,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: [31m${snapshot.error}[0m'));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    '¡Felicidades! Has visto todas tus series pendientes 🎉',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final show = item['show'];
                  final title = show != null ? show['title'] ?? 'Sin título' : 'Sin título';
                  final ids = show != null ? show['ids'] : null;
                  final traktId = ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;
                  String? posterUrl;
                  if (show != null && show['images'] != null && show['images']['poster'] != null && show['images']['poster'].isNotEmpty) {
                    posterUrl = show['images']['poster'][0];
                    if (posterUrl is String && !posterUrl.startsWith('http')) {
                      posterUrl = 'https://$posterUrl';
                    }
                  } else {
                    posterUrl = null;
                  }
                  return ShowCard(
                    traktId: traktId,
                    posterUrl: posterUrl,
                    infoWidget: _WatchProgressInfo(
                      traktId: traktId,
                      title: title,
                    ),
                    apiService: apiService,
                    parentContext: context,
                    countryCode: Localizations.localeOf(context).countryCode,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
