import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/show_details/related_show_card.dart';
import 'package:watching/show_details/related_shows_page.dart';

class ShowDetailRelated extends StatelessWidget {
  final List<dynamic>? relatedShows;
  final TraktApi apiService;
  final String countryCode;
  final String showId;
  final String showTitle;

  const ShowDetailRelated({
    super.key,
    required this.relatedShows,
    required this.apiService,
    required this.countryCode,
    required this.showId,
    required this.showTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedShows == null || relatedShows!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Relacionados',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (relatedShows!.length >= 5)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RelatedShowsPage(
                            showId: showId,
                            showTitle: showTitle,
                            apiService: apiService,
                            initialShows: relatedShows,
                          ),
                    ),
                  );
                },
                child: const Text('Ver más'),
              ),
          ],
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
                width: kRelatedShowItemWidth,
                height: kRelatedShowImageHeight,
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
