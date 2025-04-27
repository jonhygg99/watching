import 'package:flutter/material.dart';
import '../api_service.dart';

class ShowDetailHeader extends StatelessWidget {
  final Map<String, dynamic> show;
  final Map<String, dynamic>? translation;
  final bool showOriginal;
  final ValueChanged<bool> onToggleOriginal;
  final String originalTitle;
  final String originalOverview;
  final String originalTagline;
  final List<dynamic>? certifications;
  final String countryCode;
  final ApiService apiService;
  final String showId;

  const ShowDetailHeader({
    super.key,
    required this.show,
    required this.translation,
    required this.showOriginal,
    required this.onToggleOriginal,
    required this.originalTitle,
    required this.originalOverview,
    required this.originalTagline,
    required this.certifications,
    required this.countryCode,
    required this.apiService,
    required this.showId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (show['images'] != null && show['images']['poster'] != null && (show['images']['poster'] as List).isNotEmpty)
          Center(
            child: Image.network(
              'https://${show['images']['poster'][0]}',
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(showOriginal ? 'Ver en tu idioma' : 'Ver original'),
            const SizedBox(width: 10),
            Switch(
              value: showOriginal,
              onChanged: onToggleOriginal,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!showOriginal && translation != null) ...[
          Text(translation?['title'] ?? originalTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if ((translation?['tagline'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(translation?['tagline'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ),
          if ((translation?['overview'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(translation?['overview'], style: const TextStyle(fontSize: 15)),
            ),
        ] else ...[
          Text(originalTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if ((originalTagline).toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Text(originalTagline, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ),
          if ((originalOverview).toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(originalOverview, style: const TextStyle(fontSize: 15)),
            ),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            if (show['year'] != null) Chip(label: Text('Año: ${show['year']}')),
            if (show['runtime'] != null) Chip(label: Text('Duración: ${show['runtime']} min')),
            if (show['status'] != null) Chip(label: Text('Estado: ${show['status']}')),
            if (show['network'] != null) Chip(label: Text('Canal: ${show['network']}')),
            if (show['rating'] != null)
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: apiService.getShowRatings(showId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
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
                                  Icon(Icons.star, size: 56, color: Colors.amber.shade700),
                                  const SizedBox(height: 10),
                                  Text(rating.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                                  const SizedBox(height: 4),
                                  Text('$votes votos', style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 18),
                                  ...List.generate(10, (i) {
                                    final value = dist['${i+1}'] ?? 0;
                                    final percent = votes > 0 ? (value / votes) : 0.0;
                                    final color = Color.lerp(Colors.red, Colors.green, i / 9)!;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 18, child: Text('${i+1}', style: const TextStyle(fontSize: 13))),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.25),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                FractionallySizedBox(
                                                  widthFactor: percent,
                                                  child: Container(
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(width: 40, child: Text(value.toString(), style: const TextStyle(fontSize: 12))),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                child: Chip(label: Text('Rating: ${show['rating']}')),
              ),
            if ((show['genres'] as List?)?.isNotEmpty == true)
              Chip(label: Text('Géneros: ${(show['genres'] as List).join(', ')}')),
            if ((certifications)?.isNotEmpty == true)
              ...certifications!.where((c) => (c['country']?.toString()?.toLowerCase() ?? '') == countryCode.substring(0, 2).toLowerCase())
                .map((c) => Chip(label: Text('Certificado: ${c['certification']}'))),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
