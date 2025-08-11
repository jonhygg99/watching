import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/shared/constants/measures.dart';

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

  // Map to track which shows are expanded
  final Map<int, bool> _expandedShows = {};

  Widget _buildShowList(List<dynamic> items) {
    if (items.isEmpty) {
      return Center(child: Text('No shows found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final showData = items[index];
        final show = showData['show'] ?? {};
        final episodes = List<Map<String, dynamic>>.from(
          showData['episodes'] ?? [],
        );

        // Sort episodes by air date
        episodes.sort(
          (a, b) => (a['first_aired'] as String).compareTo(
            b['first_aired'] as String,
          ),
        );

        // Get the next airing episode
        final nextEpisode = episodes.isNotEmpty ? episodes[0] : null;
        final airDate =
            nextEpisode != null
                ? DateTime.tryParse(nextEpisode['first_aired'])
                : null;
        final daysUntil = airDate?.difference(DateTime.now()).inDays ?? 0;
        final isSeasonPremiere =
            nextEpisode != null && nextEpisode['episode'] == 1;

        // Initialize expanded state if not exists
        _expandedShows.putIfAbsent(index, () => false);

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show poster
                      if (show['images']?['poster'] is List &&
                          (show['images']!['poster'] as List).isNotEmpty)
                        ClipRRect(
                          borderRadius: kShowBorderRadius,
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://${(show['images']!['poster'] as List).first}',
                            width: kMyShowItemWidth,
                            height: kMyShowImageHeight,
                            fit: BoxFit.cover,
                            errorWidget:
                                (context, url, error) => Container(
                                  width: kMyShowItemWidth,
                                  height: kMyShowImageHeight,
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.tv,
                                    size: 30,
                                    color: Colors.white30,
                                  ),
                                ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: kShowBorderRadius,
                          ),
                          width: kMyShowItemWidth,
                          height: kMyShowImageHeight,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.tv,
                            size: 30,
                            color: Colors.white30,
                          ),
                        ),

                      const SizedBox(width: 16),

                      // Show and episode info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              show['title']?.toString() ?? 'Unknown Show',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSeasonPremiere
                                  ? 'Season Premiere'
                                  : 'S${nextEpisode?['season'].toString().padLeft(2, '0')} • E${nextEpisode?['episode'].toString().padLeft(2, '0')}',
                            ),
                            const SizedBox(height: 4),
                            if (airDate != null)
                              Text(
                                '${_formatDate(airDate)} • ${_formatTime(airDate)}',
                              ),
                            if (episodes.length > 1)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _expandedShows[index] =
                                        !_expandedShows[index]!;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  _expandedShows[index]!
                                      ? 'Hide episodes'
                                      : 'Show ${episodes.length - 1} more episodes',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Days until bubble
                      if (daysUntil >= 0) _buildDaysBubble(daysUntil),
                    ],
                  ),
                  if (_expandedShows[index]! && episodes.length > 1)
                    ...episodes.sublist(1).map((episode) {
                      final airDate = DateTime.tryParse(
                        episode['first_aired'] ?? '',
                      );
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 76,
                          right: 16,
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'S${episode['season'].toString().padLeft(2, '0')}E${episode['episode'].toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                airDate != null
                                    ? '${_formatDate(airDate)} • ${_formatTime(airDate)} • ${_getDaysUntil(airDate)}'
                                    : 'TBA',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDaysBubble(int days) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.only(left: 8, right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A), // Purple color
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9C27B0), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            days.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'days',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour < 12 ? 'a.m.' : 'p.m.';
    return '$hour:$minute $amPm';
  }

  String _getDaysUntil(DateTime airDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final airDateStart = DateTime(airDate.year, airDate.month, airDate.day);
    final difference = airDateStart.difference(today);
    final days = difference.inDays;

    if (days < 0) return 'Aired';
    if (days == 0) return 'Today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }
}
