import 'package:flutter/material.dart';
import '../show_carousel.dart';
import '../api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../show_details/details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
      ),
      body: _query.isEmpty
          ? FutureBuilder<List<dynamic>>(
              future: apiService.getTrendingShows(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay shows en tendencia.'));
                }
                final all = snapshot.data!;
                for (final item in all) {
                  print('ITEM TYPE: \\${item.runtimeType}, VALUE: \\${item.toString()}');
                }
                final shows = all.where((item) => item is Map && item['show'] is Map).toList();
                if (shows.isEmpty) {
                  return const Center(child: Text('No hay shows válidos para mostrar.'));
                }
                return GridView.count(
                  padding: const EdgeInsets.all(12),
                  crossAxisCount: 3,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 0,
                  children: [
                    for (final item in shows)
                      _ShowGridTile(
                        show: Map<String, dynamic>.from(item['show'] as Map),
                        onTap: () {
                          final show = Map<String, dynamic>.from(item['show'] as Map);
                          final showId = show['ids']?['trakt']?.toString() ?? show['ids']?['slug'] ?? '';
                          if (showId.isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ShowDetailPage(
                                showId: showId,
                                apiService: apiService,
                                countryCode: Localizations.localeOf(context).countryCode ?? 'US',
                              ),
                            ),
                          );
                        },
                      )
                  ],
                );
              },
            )
          : Center(
              child: Text('Resultados para "$_query"'),
            ),
    );
  }
}

class _ShowGridTile extends StatelessWidget {
  final Map<String, dynamic> show;
  final VoidCallback? onTap;
  const _ShowGridTile({required this.show, this.onTap});

  String? getPosterUrl(dynamic posterList) {
    if (posterList is List && posterList.isNotEmpty && posterList.first is String) {
      final url = posterList.first as String;
      if (url.startsWith('http')) return url;
      return 'https://$url';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final images = show['images'] as Map<String, dynamic>?;
    final poster = getPosterUrl(images?['poster']);
    final title = show['title'] ?? 'Sin título';
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child: poster != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: poster,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 48),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}
