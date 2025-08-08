import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'cast_guest.dart';

class ShowDetailCast extends StatelessWidget {
  final Map<String, dynamic>? people;
  final String showId;
  final TraktApi apiService;
  const ShowDetailCast({
    super.key,
    required this.people,
    required this.showId,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    if (people == null ||
        people!['cast'] == null ||
        (people!['cast'] as List).isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reparto principal',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: (people!['cast'] as List).length,
            separatorBuilder: (_, __) => const SizedBox(width: 0),
            itemBuilder: (context, i) {
              final actor = people!['cast'][i];
              final person = actor['person'] ?? {};
              final name = person['name'] ?? '';
              final character =
                  (actor['characters'] != null &&
                          actor['characters'] is List &&
                          actor['characters'].isNotEmpty)
                      ? actor['characters'][0]
                      : '';
              final imgPath = person['images']?['tmdb']?['avatar'];
              final imgUrl =
                  (imgPath != null && imgPath.toString().isNotEmpty)
                      ? 'https://image.tmdb.org/t/p/w185$imgPath'
                      : null;
              return Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage:
                        imgUrl != null ? NetworkImage(imgUrl) : null,
                    child:
                        imgUrl == null
                            ? Text(
                              name.isNotEmpty ? name[0] : '?',
                              style: const TextStyle(fontSize: 36),
                            )
                            : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 120,
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        GuestStarsSection(showId: showId, apiService: apiService),
      ],
    );
  }
}
