import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

class GuestStarsSection extends StatefulWidget {
  final String showId;
  final TraktApi apiService;
  const GuestStarsSection({
    super.key,
    required this.showId,
    required this.apiService,
  });

  @override
  State<GuestStarsSection> createState() => _GuestStarsSectionState();
}

class _GuestStarsSectionState extends State<GuestStarsSection> {
  bool _showGuestStars = false;
  Future<List<dynamic>>? _guestStarsFuture;
  List<dynamic>? _guestStarsCache;

  void _toggleGuestStars(bool val) {
    setState(() {
      _showGuestStars = val;
      if (val && _guestStarsCache == null) {
        _guestStarsFuture = widget.apiService
            .getShowPeople(id: widget.showId, extended: true)
            .then((data) => data['guest_stars'] as List<dynamic>? ?? []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Mostrar guest stars',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Switch(value: _showGuestStars, onChanged: _toggleGuestStars),
          ],
        ),
        if (_showGuestStars)
          FutureBuilder<List<dynamic>>(
            future:
                _guestStarsCache != null
                    ? Future.value(_guestStarsCache)
                    : _guestStarsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Error cargando guest stars',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              final guestStars = snapshot.data ?? [];
              if (_guestStarsCache == null && guestStars.isNotEmpty)
                _guestStarsCache = guestStars;
              if (guestStars.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No hay guest stars.'),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  const Text(
                    'Guest stars',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: guestStars.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final actor = guestStars[i];
                        final person = actor['person'] ?? {};
                        final name = person['name'] ?? '';
                        final character =
                            (actor['characters'] != null &&
                                    actor['characters'] is List &&
                                    actor['characters'].isNotEmpty)
                                ? actor['characters'][0]
                                : '';
                        // TODO: fix images
                        final imgPath = person['images']?['tmdb']?['avatar'];
                        final imgUrl =
                            (imgPath != null && imgPath.toString().isNotEmpty)
                                ? 'https://image.tmdb.org/t/p/w185$imgPath'
                                : null;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 48,
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
