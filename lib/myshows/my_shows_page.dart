import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

class MyShowsPage extends StatefulWidget {
  const MyShowsPage({super.key});

  @override
  State<MyShowsPage> createState() => _MyShowsPageState();
}

class _MyShowsPageState extends State<MyShowsPage>
    with TickerProviderStateMixin {
  List<dynamic>? _calendarData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCalendar();
  }

  Future<void> _fetchCalendar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final trakt = TraktApi();
      final now = DateTime.now();
      final startDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await trakt.getMyShowsCalendar(
        startDate: startDate,
        days: 365, // Get next 365 days
      );

      final data = response['data'] as List<dynamic>;

      // Group episodes by show ID
      final Map<String, Map<String, dynamic>> groupedShows = {};

      for (final episode in data) {
        final showId = episode['show']['ids']['trakt'].toString();

        if (!groupedShows.containsKey(showId)) {
          groupedShows[showId] = {
            'id': showId,
            'show': episode['show'],
            'episodes': [],
          };
        }

        groupedShows[showId]!['episodes'].add({
          'season': episode['episode']['season'],
          'episode': episode['episode']['number'],
          'first_aired': episode['first_aired'],
          'title': episode['episode']['title'],
        });
      }

      // Convert the map to a list and sort by first_aired
      final List<dynamic> processedData =
          groupedShows.values.toList()..sort(
            (a, b) => (a['episodes'][0]['first_aired'] as String).compareTo(
              b['episodes'][0]['first_aired'] as String,
            ),
          );

      setState(() {
        _calendarData = processedData;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      log('Error fetching calendar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shows')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _buildShowList(_calendarData ?? []),
    );
  }

  Widget _buildShowList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No shows found'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final showData = items[index];
        final show = showData['show'] ?? {};
        final episodes = List<Map<String, dynamic>>.from(
          showData['episodes'] ?? [],
        );

        // Sort episodes by season and episode number
        episodes.sort((a, b) {
          final seasonCompare = (a['season'] as int).compareTo(
            b['season'] as int,
          );
          if (seasonCompare != 0) return seasonCompare;
          return (a['episode'] as int).compareTo(b['episode'] as int);
        });

        // Get the next airing episode (first in the list since we sorted by date)
        final nextEpisode = episodes.isNotEmpty ? episodes[0] : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading:
                show['images']?['poster']?[0] != null
                    ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w200${show['images']['poster'][0]}',
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    )
                    : const Icon(Icons.tv, size: 50),
            title: Text(show['title']?.toString() ?? 'Unknown Show'),
            subtitle:
                nextEpisode != null
                    ? Text(
                      'Next: S${nextEpisode['season'].toString().padLeft(2, '0')}E${nextEpisode['episode'].toString().padLeft(2, '0')} - ${nextEpisode['title'] ?? 'Untitled'}\nAirs: ${DateTime.tryParse(nextEpisode['first_aired'])?.toLocal() ?? 'TBA'}',
                    )
                    : const Text('No upcoming episodes'),
            children: [
              if (episodes.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Upcoming Episodes (${episodes.length}):',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...episodes
                    .map(
                      (episode) => ListTile(
                        dense: true,
                        title: Text(
                          'S${episode['season'].toString().padLeft(2, '0')}'
                          'E${episode['episode'].toString().padLeft(2, '0')} - '
                          '${episode['title'] ?? 'Untitled'}',
                        ),
                        subtitle: Text(
                          'Airs: ${DateTime.tryParse(episode['first_aired'])?.toLocal() ?? 'TBA'}',
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}
