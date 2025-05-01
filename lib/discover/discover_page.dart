import 'package:flutter/material.dart';
import '../show_carousel.dart';
import '../api_service.dart';

import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Discover',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// class DiscoverPage extends StatelessWidget {
//   const DiscoverPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView(
//         children: [
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Trending Shows',
//             future: apiService.getTrendingShows(),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows en tendencia.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Popular Shows',
//             future: apiService.getPopularShows(),
//             extractShow: (item) => Map<String, dynamic>.from(item),
//             emptyText: 'No hay shows populares.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Favorited (7 días)',
//             future: apiService.getMostFavoritedShows(period: 'weekly'),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows más favoritos de la semana.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Favorited (30 días)',
//             future: apiService.getMostFavoritedShows(period: 'monthly'),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows más favoritos del mes.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Collected (7 días)',
//             future: apiService.getMostCollectedShows(period: 'weekly'),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows más coleccionados de la semana.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Played (7 días)',
//             future: apiService.getMostPlayedShows(period: 'weekly'),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows más reproducidos de la semana.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Watched (7 días)',
//             future: apiService.getMostWatchedShows(period: 'weekly'),
//             extractShow: (item) => item['show'],
//             emptyText: 'No hay shows más vistos de la semana.',
//           ),
//           const SizedBox(height: 16),
//           ShowCarousel(
//             title: 'Most Anticipated',
//             future: apiService.getMostAnticipatedShows(),
//             extractShow:
//                 (item) => {
//                   ...Map<String, dynamic>.from(item['show']),
//                   'list_count': item['list_count'],
//                 },
//             emptyText: 'No hay shows anticipados.',
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
