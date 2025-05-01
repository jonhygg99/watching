import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../show_carousel.dart';
import '../api_service.dart';

/// DiscoverPage displays various carousels of TV shows using data from the ApiService.
/// Uses Riverpod for dependency injection and best practices.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Riverpod to get the ApiService instance
    final api = ref.watch(apiServiceProvider);

    // Helper for each carousel to ensure consistent error/loading handling
    Widget buildCarousel({
      required String title,
      required Future<List<dynamic>> future,
      required Map<String, dynamic> Function(dynamic) extractShow,
      required String emptyText,
    }) {
      return FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Error al cargar: [${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          return ShowCarousel(
            title: title,
            shows: items,
            extractShow: extractShow,
            emptyText: emptyText,
          );
        },
      );
    }

    // Ensure this ListView is NOT wrapped in a SingleChildScrollView or constrained parent.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        key: const PageStorageKey(
          'discover-list',
        ), // helps preserve scroll position
        // Do NOT set shrinkWrap or physics here!
        children: [
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Trending Shows',
            future: api.getTrendingShows(),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows en tendencia.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Popular Shows',
            future: api.getPopularShows(),
            extractShow: (item) => Map<String, dynamic>.from(item),
            emptyText: 'No hay shows populares.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (7 días)',
            future: api.getMostFavoritedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows más favoritos de la semana.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (30 días)',
            future: api.getMostFavoritedShows(period: 'monthly'),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows más favoritos del mes.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Collected (7 días)',
            future: api.getMostCollectedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows más coleccionados de la semana.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Played (7 días)',
            future: api.getMostPlayedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows más reproducidos de la semana.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Watched (7 días)',
            future: api.getMostWatchedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No hay shows más vistos de la semana.',
          ),
          const SizedBox(height: 16),
          buildCarousel(
            title: 'Most Anticipated',
            future: api.getMostAnticipatedShows(),
            extractShow:
                (item) => {
                  ...Map<String, dynamic>.from(item['show']),
                  'list_count': item['list_count'],
                },
            emptyText: 'No hay shows anticipados.',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Riverpod provider for ApiService singleton.
final apiServiceProvider = Provider<ApiService>((ref) => apiService);
