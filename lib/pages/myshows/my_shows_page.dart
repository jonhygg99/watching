import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/pages/myshows/widgets/calendar/calendar.dart';
import 'package:watching/pages/myshows/widgets/my_shows_skeleton.dart';
import 'package:watching/pages/myshows/widgets/shows_list/shows_list_content.dart';
import 'package:watching/pages/myshows/providers/upcoming_episodes_provider.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/api/trakt/trakt_api.dart';

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

  // Add this provider if it doesn't exist in your project
  final countryCodeProvider = StateProvider<String>((ref) => '');

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
          AppLocalizations.of(context)!.calendarDataError,
          style: const TextStyle(color: kErrorColorMessage),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_calendarData?.isNotEmpty ?? false) ...[
            Padding(padding: const EdgeInsets.only(top: kPhoneSpaceVertical)),
            Calendar(items: _calendarData ?? []),
          ],
          ShowsList(
            type: ShowsListType.waiting,
            title: AppLocalizations.of(context)!.waitingForNextSeason,
          ),
          const SizedBox(height: 24),
          ShowsList(type: ShowsListType.ended, title: AppLocalizations.of(context)!.endedShows),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
