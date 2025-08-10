import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

class MyShowsPage extends StatefulWidget {
  const MyShowsPage({super.key});

  @override
  State<MyShowsPage> createState() => _MyShowsPageState();
}

class _MyShowsPageState extends State<MyShowsPage> with TickerProviderStateMixin {
  List<dynamic>? _calendarData;
  List<dynamic>? _premieresData;
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCalendar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      final response1 = await trakt.getMyShowsCalendar(
        startDate: startDate,
        days: 365, // Get next 365 days
      );
      final response2 = await trakt.getMyShowsPremieres(
        startDate: startDate,
        days: 365, // Get next 365 days
      );
      final response3 = await trakt.getMyNewShows(
        startDate: startDate,
        days: 365, // Get next 365 days
      );

      final data1 = response1['data'] as List<dynamic>;
      final data2 = response2['data'] as List<dynamic>;
      final data3 = response3['data'] as List<dynamic>;

      setState(() {
        _calendarData = data1;
        _premieresData = data2;
        
        if (data2.isNotEmpty) {
          debugPrint('Total premieres: ${data2.length}');
        }
        if (data3.isNotEmpty) {
          debugPrint('Total new shows: ${data3.length}');
        }
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
      appBar: AppBar(
        title: const Text('My Shows'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Premieres'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Upcoming Episodes Tab
                    _buildShowList(_calendarData ?? []),
                    // Premieres Tab
                    _buildShowList(_premieresData ?? []),
                  ],
                ),
    );
  }

  Widget _buildShowList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No shows found'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final show = item['show'] ?? {};
        final episode = item['episode'] ?? {};
        final firstAired = item['first_aired'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(show['title']?.toString() ?? 'Unknown Show'),
            subtitle: Text(
              'S${episode['season']?.toString().padLeft(2, '0') ?? '??'}'
              'E${episode['number']?.toString().padLeft(2, '0') ?? '??'} - '
              '${episode['title']?.toString() ?? 'Untitled'}\n'
              'Airs: ${firstAired != null ? DateTime.parse(firstAired).toLocal() : 'TBA'}',
            ),
            leading: show['images']?['poster']?[0] != null
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w200${show['images']['poster'][0]}',
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                : const Icon(Icons.tv, size: 50),
          ),
        );
      },
    );
  }
}
