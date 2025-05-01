import 'package:flutter/material.dart';
import 'package:watching/api_service.dart';
import 'package:watching/watchlist/show_card.dart';
import 'package:watching/watchlist/watch_progress_info.dart';

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
    final futures =
        items.map((item) async {
          final show = item['show'];
          final ids = show != null ? show['ids'] : null;
          final traktId =
              ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;
          if (traktId != null) {
            try {
              final progress = await apiService.getShowWatchedProgress(
                id: traktId,
              );
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
              const Text(
                'Tipo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                  final title =
                      show != null
                          ? show['title'] ?? 'Sin título'
                          : 'Sin título';
                  final ids = show != null ? show['ids'] : null;
                  final traktId =
                      ids != null
                          ? ids['slug'] ?? ids['trakt']?.toString()
                          : null;
                  String? posterUrl;
                  if (show != null &&
                      show['images'] != null &&
                      show['images']['poster'] != null &&
                      show['images']['poster'].isNotEmpty) {
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
                    infoWidget: WatchProgressInfo(
                      traktId: traktId,
                      title: title,
                      apiService: apiService,
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
