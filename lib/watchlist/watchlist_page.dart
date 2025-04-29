import 'package:flutter/material.dart';
import 'package:watching/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:io';

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
    _futureWatchlist = apiService.getWatched(type: _type);
  }

  void _onTypeChanged(String? newType) {
    if (newType == null) return;
    setState(() {
      _type = newType;
      _futureWatchlist = apiService.getWatched(type: _type);
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
                return const Center(child: Text('No hay elementos en la colección.'));
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
                  return Card(
                    child: ListTile(
                      leading: posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 50, height: 75, color: Colors.grey),
                      title: Text(title),
                      trailing: traktId != null
                          ? IconButton(
                              icon: Icon(Icons.info_outline),
                              tooltip: 'Ver progreso',
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Center(child: CircularProgressIndicator()),
                                );
                                try {
                                  final progress = await apiService.getShowWatchedProgress(id: traktId);
                                  Navigator.of(context).pop(); // Remove loading dialog
                                  final episodesWatched = progress['completed'];
                                  final totalEpisodes = progress['aired'];
                                  final nextEpisode = progress['next_episode'];
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Progreso de la serie'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Episodios vistos: $episodesWatched'),
                                          Text('Total episodios: $totalEpisodes'),
                                          if (nextEpisode != null)
                                            Text('Próximo episodio pendiente: '
                                              'T${nextEpisode['season']}E${nextEpisode['number']} - ${nextEpisode['title']}')
                                          else
                                            Text('No hay episodios pendientes.'),
                                        ],
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.of(context).pop(); // Remove loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            )
                          : null,
                    ),
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
