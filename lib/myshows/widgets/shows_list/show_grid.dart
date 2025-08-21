import 'package:flutter/material.dart';
import 'package:watching/myshows/widgets/show_poster.dart';
import 'package:watching/shared/pages/show_details/details_page.dart';

class ShowGrid extends StatelessWidget {
  final List<Map<String, dynamic>> shows;
  final double spacing;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisExtentMultiplier;

  const ShowGrid({
    super.key,
    required this.shows,
    this.spacing = 8.0,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.6,
    this.mainAxisExtentMultiplier = 1.67,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the available width for the grid
        final width = constraints.maxWidth;
        // Calculate item width based on crossAxisCount and spacing
        final itemWidth = (width - (spacing * (crossAxisCount - 1)) - 16.0) / 
                         crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemWidth * mainAxisExtentMultiplier,
          ),
          itemCount: shows.length,
          itemBuilder: (context, index) {
            final showData = shows[index];
            final show = _convertToTypedMap(showData['show'] ?? showData);
            final traktId = show['ids']?['trakt']?.toString() ??
                          show['ids']?['slug']?.toString();

            return GestureDetector(
              onTap: traktId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowDetailPage(showId: traktId),
                        ),
                      );
                    },
              child: ShowPoster(show: show),
            );
          },
        );
      },
    );
  }

  // Helper method to safely convert dynamic maps to Map<String, dynamic>
  static Map<String, dynamic> _convertToTypedMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
