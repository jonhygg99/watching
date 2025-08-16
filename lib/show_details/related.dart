import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/show_details/related_show_card.dart';

class ShowDetailRelated extends StatelessWidget {
  final List<dynamic>? relatedShows;
  final TraktApi apiService;
  final String countryCode;
  const ShowDetailRelated({
    super.key,
    required this.relatedShows,
    required this.apiService,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedShows == null || relatedShows!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Relacionados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: relatedShows!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              return RelatedShowCard(
                showData: relatedShows![i],
                width: 160,
                height: 240,
                imageHeight: 200,
                borderRadius: 12,
                spacing: 8,
              );
            },
          ),
        ),
      ],
    );
  }
}
