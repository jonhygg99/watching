import 'package:flutter/material.dart';
import '../api_service.dart';
import 'details_page.dart';

class ShowDetailRelated extends StatelessWidget {
  final List<dynamic>? relatedShows;
  final ApiService apiService;
  final String countryCode;
  const ShowDetailRelated({super.key, required this.relatedShows, required this.apiService, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    if (relatedShows == null || relatedShows!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Relacionados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: relatedShows!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final r = relatedShows![i];
              final img = (r['images']?['poster'] as List?)?.isNotEmpty == true ? r['images']['poster'][0] : null;
              return GestureDetector(
                onTap: () {
                  final relatedId = r['ids']?['slug'] ?? r['ids']?['trakt']?.toString() ?? r['ids']?['imdb'] ?? '';
                  if (relatedId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowDetailPage(
                          showId: relatedId,
                        ),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (img != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://$img',
                            height: 150,
                            width: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              width: 110,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 40),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          width: 110,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        ),
                      const SizedBox(height: 4),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          r['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
