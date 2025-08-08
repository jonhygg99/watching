import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

class ShowInfoChips extends StatelessWidget {
  final Map<String, dynamic> show;
  final List<dynamic>? certifications;
  final String countryCode;

  const ShowInfoChips({
    super.key,
    required this.show,
    this.certifications,
    this.countryCode = 'ES',
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        if ((show['genres'] as List?)?.isNotEmpty == true)
          Chip(label: Text('Géneros: ${(show['genres'] as List).join(', ')}')),
        if ((certifications)?.isNotEmpty == true)
          ...certifications!
              .where(
                (c) =>
                    (c['country']?.toString().toLowerCase() ?? '') ==
                    countryCode.substring(0, 2).toLowerCase(),
              )
              .map(
                (c) => Chip(label: Text('Certificado: ${c['certification']}')),
              ),
        if (show['year'] != null) Chip(label: Text('Año: ${show['year']}')),
        if (show['runtime'] != null)
          Chip(label: Text('Duración: ${show['runtime']} min')),
        if (show['status'] != null)
          Chip(label: Text('Estado: ${show['status']}')),
        if (show['network'] != null)
          Chip(label: Text('Canal: ${show['network']}')),
        if (show['rating'] != null)
          GestureDetector(
            onTap: () => _showRatingsDialog(context, show['id'].toString()),
            child: Chip(label: Text('Rating: ${show['rating']}')),
          ),
        if (show['genres'] != null && (show['genres'] as List).isNotEmpty)
          Chip(label: Text('Géneros: ${(show['genres'] as List).join(', ')}')),
        if (show['certification'] != null)
          Chip(label: Text('Certificación: ${show['certification']}')),
      ],
    );
  }

  void _showRatingsDialog(BuildContext context, String showId) {
    final apiService = TraktApi();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder<Map<String, dynamic>>(
            future: apiService.getShowRatings(id: showId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Error cargando ratings'),
                );
              }

              final data = snapshot.data!;
              final rating = data['rating'] ?? 0.0;
              final votes = data['votes'] ?? 0;
              final dist = data['distribution'] as Map<String, dynamic>? ?? {};

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Valoración de la comunidad',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 36),
                      ],
                    ),
                    Text(
                      'Basado en $votes votos',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(10, (index) {
                      final ratingValue = 10 - index;
                      final count = (dist[ratingValue.toString()] ?? 0).toInt();
                      final percentage =
                          votes > 0 ? (count / votes * 100).round() : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Text(
                                '$ratingValue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$percentage%',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
