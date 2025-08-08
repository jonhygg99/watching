import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../show_details/details_page.dart';
import 'search_result_item.dart';
import '../api/trakt/show_translation.dart';

/// Grid for trending shows using Freezed model and improved tile widget.
class TrendingGrid extends ConsumerWidget {
  final List<dynamic>? initialTrendingShows;
  
  const TrendingGrid({super.key, this.initialTrendingShows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialTrendingShows != null) {
      return GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final item in initialTrendingShows!)
            SearchResultGridTile(
              item: SearchResultItem(
                data: item['show'],
                type: 'show',
              ),
              onTap: () {
                final show = item['show'];
                final showId =
                    show['ids']?['trakt']?.toString() ??
                    show['ids']?['slug'] ??
                    '';
                if (showId.isEmpty) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShowDetailPage(showId: showId),
                  ),
                );
              },
            ),
        ],
      );
    }
    
    final api = ref.watch(traktApiProvider);
    final translationService = ref.watch(showTranslationServiceProvider);
    final countryCode = ref.watch(countryCodeProvider);
    
    return FutureBuilder<List<dynamic>>(
      future: api.getTrendingShows(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final shows = snapshot.data ?? [];
        if (shows.isEmpty) {
          return const Center(child: Text('No hay shows en tendencia.'));
        }
        
        // Process shows to get translated titles
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(shows.map((item) async {
            var showData = Map<String, dynamic>.from(item['show'] as Map);
            
            // Only translate if it's a show
            if (countryCode.isNotEmpty) {
              final title = await translationService.getTranslatedTitle(
                show: showData,
                traktApi: api,
              );
              if (title != showData['title']) {
                showData = Map<String, dynamic>.from(showData)..['title'] = title;
              }
            }
            
            return {
              'show': showData,
              'originalShow': item['show'],
            };
          })),
          builder: (context, processedSnapshot) {
            if (processedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final processedShows = processedSnapshot.data ?? [];
            
            return GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final item in processedShows)
                  SearchResultGridTile(
                    item: SearchResultItem(
                      data: item['show'],
                      type: 'show',
                    ),
                    onTap: () {
                      final show = item['originalShow'];
                      final showId =
                          show['ids']?['trakt']?.toString() ??
                          show['ids']?['slug'] ??
                          '';
                      if (showId.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowDetailPage(showId: showId),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
