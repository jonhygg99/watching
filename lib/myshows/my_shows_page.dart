import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/myshows/widgets/my_shows_skeleton.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/pages/myshows/providers/upcoming_episodes_provider.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/myshows/waiting_shows.dart';
import 'package:watching/myshows/ended_shows.dart';
import 'package:watching/myshows/show_list_item.dart';

class MyShowsPage extends ConsumerStatefulWidget {
  const MyShowsPage({super.key});

  @override
  ConsumerState<MyShowsPage> createState() => _MyShowsPageState();
}

class _MyShowsPageState extends ConsumerState<MyShowsPage>
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

      // Get user's country code for translations
      final countryCode = ref.read(countryCodeProvider);
      final language =
          countryCode.isNotEmpty ? countryCode.toLowerCase() : null;

      final response = await trakt.getMyShowsCalendar(
        startDate: startDate,
        days: 365, // Get next 365 days
        language: language,
      );

      final data = response['data'] as List<dynamic>;

      // Track show IDs with upcoming episodes
      final Set<int> showsWithUpcomingEpisodes = {};

      // Group episodes by show ID
      final Map<String, Map<String, dynamic>> groupedShows = {};

      // First pass: collect all show IDs with upcoming episodes
      for (final episode in data) {
        final traktId = episode['show']?['ids']?['trakt'] as int?;
        if (traktId != null) {
          showsWithUpcomingEpisodes.add(traktId);
        }
      }

      // Update the provider with the complete set of shows with upcoming episodes
      if (mounted) {
        ref
            .read(upcomingEpisodesProvider.notifier)
            .setShowsWithUpcomingEpisodes(showsWithUpcomingEpisodes);
      }

      // Second pass: group episodes by show ID
      for (final episode in data) {
        final showId = episode['show']?['ids']?['trakt']?.toString();
        if (showId == null) continue;

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
    if (_isLoading) {
      return const MyShowsSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_calendarData?.isNotEmpty ?? false) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Upcoming Episodes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _buildShowList(_calendarData ?? []),
          ],
          const WaitingShows(),
          const SizedBox(height: 24),
          const EndedShows(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Map to track which shows are expanded
  final Map<int, bool> _expandedShows = {};

  Widget _buildShowList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No shows found'));
    }

    return Column(
      children:
          items.asMap().entries.map((entry) {
            final index = entry.key;
            final showData = entry.value;
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
          }).toList(),
    );
  }
}
