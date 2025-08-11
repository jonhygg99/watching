import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/myshows/show_list_item.dart';

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
      debugPrint('Error fetching calendar: $e');
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
      return const Center(child: Text('No shows found'));
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

        // Initialize expanded state if not exists
        _expandedShows.putIfAbsent(index, () => false);

        return StatefulBuilder(
          builder: (context, setState) {
            return ShowListItem(
              show: show,
              episodes: episodes,
              isExpanded: _expandedShows[index]!,
              onToggleExpand: () {
                setState(() {
                  _expandedShows[index] = !_expandedShows[index]!;
                });
              },
            );
          },
        );
      },
    );
  }
}
