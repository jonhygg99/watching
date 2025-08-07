import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/show_details/details_page.dart';
import 'package:watching/services/trakt/trakt_api.dart';

class ShowCard extends StatelessWidget {
  final String? traktId;
  final String? posterUrl;
  final Widget infoWidget;
  final TraktApi apiService;
  final BuildContext parentContext;

  const ShowCard({
    super.key,
    required this.traktId,
    required this.posterUrl,
    required this.infoWidget,
    required this.apiService,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          traktId != null
              ? () {
                Navigator.of(parentContext).push(
                  MaterialPageRoute(
                    builder: (_) => ShowDetailPage(showId: traktId!),
                  ),
                );
              }
              : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        elevation: 0,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: kShowBorderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Poster grande y redondeado
            ClipRRect(
              borderRadius: kShowBorderRadius,
              child:
                  posterUrl != null
                      ? CachedNetworkImage(
                        imageUrl: posterUrl!,
                        width: 110, // Increased from 90
                        height:
                            165, // Increased from 135 (maintaining 2:3 aspect ratio)
                        fit: BoxFit.cover,
                      )
                      : Container(width: 110, height: 165, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            // Info principal
            Expanded(child: infoWidget),
          ],
        ),
      ),
    );
  }
}
