import 'package:flutter/material.dart';
import 'api_service.dart';
import 'guest_stars_section.dart';

class ShowDetailPage extends StatefulWidget {
  final String showId;
  final ApiService apiService;
  final String countryCode;

  const ShowDetailPage({super.key, required this.showId, required this.apiService, required this.countryCode});

  @override
  State<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends State<ShowDetailPage> {
  bool _showOriginal = false;
  String _sort = 'likes';
  late Future<List<dynamic>> _commentsFuture;


  static const Map<String, String> _sortLabels = {
    'likes': 'Más likes',
    'newest': 'Más recientes',
    'oldest': 'Más antiguos',
    'replies': 'Más respuestas',
    'highest': 'Mejor valorados',
    'lowest': 'Peor valorados',
    'plays': 'Más reproducidos',
    'watched': 'Más vistos',
  };

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.apiService.getShowComments(widget.showId, sort: _sort);
  }

  void _changeSort(String? value) {
    if (value == null || value == _sort) return;
    setState(() {
      _sort = value;
      _commentsFuture = widget.apiService.getShowComments(widget.showId, sort: _sort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Show')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          widget.apiService.getShowById(widget.showId),
          widget.apiService.getShowTranslations(widget.showId, widget.countryCode.substring(0, 2).toLowerCase()),
          widget.apiService.getShowCertifications(widget.showId),
          widget.apiService.getShowPeople(widget.showId), // cast y crew
          widget.apiService.getRelatedShows(widget.showId), // shows relacionados
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          final results = snapshot.data;
          if (results == null || results.length < 5) {
            return const Center(child: Text('No se encontraron datos.'));
          }
          final show = results[0] as Map<String, dynamic>?;
          final translations = results[1] as List<dynamic>?;
          final certifications = results[2] as List<dynamic>?;
          final people = results[3] as Map<String, dynamic>?;
          final relatedShows = results[4] as List<dynamic>?;
          if (show == null) {
            return const Center(child: Text('No se encontraron datos.'));
          }

          // Buscar traducción para el idioma del usuario
          Map<String, dynamic>? translation;
          if (translations != null && translations.isNotEmpty) {
            translation = translations.firstWhere(
              (t) => t['language']?.toString()?.toLowerCase() == widget.countryCode.substring(0, 2).toLowerCase(),
              orElse: () => null,
            );
          }

          final originalTitle = show['title'] ?? '';
          final originalOverview = show['overview'] ?? '';
          final originalTagline = show['tagline'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                    Text(_showOriginal ? 'Ver en tu idioma' : 'Ver original'),
                    const SizedBox(width: 10),
                    Switch(
                      value: _showOriginal,
                      onChanged: (val) => setState(() => _showOriginal = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!_showOriginal && translation != null) ...[
                  Text(translation['title'] ?? originalTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if ((translation['tagline'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      child: Text(translation['tagline'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                    ),
                  if ((translation['overview'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(translation['overview'], style: const TextStyle(fontSize: 15)),
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
                    if (show['year'] != null) Chip(label: Text('Año: \\${show['year']}')),
                    if (show['runtime'] != null) Chip(label: Text('Duración: \\${show['runtime']} min')),
                    if (show['status'] != null) Chip(label: Text('Estado: \\${show['status']}')),
                    if (show['network'] != null) Chip(label: Text('Canal: \\${show['network']}')),
                    if (show['rating'] != null)
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: widget.apiService.getShowRatings(widget.showId),
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
                    if (show['genres'] != null && show['genres'] is List && show['genres'].isNotEmpty)
                      Chip(label: Text('Géneros: \\${(show['genres'] as List).join(', ')}')),
                    if (certifications != null && certifications.isNotEmpty)
                      ...certifications.where((c) => (c['country']?.toString()?.toLowerCase() ?? '') == widget.countryCode.substring(0, 2).toLowerCase())
                        .map((c) => Chip(label: Text('Certificado: \\${c['certification']}'))),
                  ],
                ),
                const SizedBox(height: 20),
                // --- Lista horizontal de actores principales ---
                if (people != null && people['cast'] != null && (people['cast'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reparto principal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: (people['cast'] as List).length,
                          separatorBuilder: (_, __) => const SizedBox(width: 0),
                          itemBuilder: (context, i) {
                            final actor = people['cast'][i];
                            final person = actor['person'] ?? {};
                            final name = person['name'] ?? '';
                            final character = (actor['characters'] != null && actor['characters'] is List && actor['characters'].isNotEmpty)
                              ? actor['characters'][0] : '';
                            final imgPath = person['images']?['tmdb']?['avatar'];
                            final imgUrl = (imgPath != null && imgPath.toString().isNotEmpty)
                              ? 'https://image.tmdb.org/t/p/w185$imgPath' : null;
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 42,
                                  backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                                  child: imgUrl == null ? Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: const TextStyle(fontSize: 36),
                                  ) : null,
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 120,
                                  child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(character, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // --- Sección de guest stars, gestionada aparte ---
                      GuestStarsSection(showId: widget.showId, apiService: widget.apiService),
                    ],
                  ),
                // --- Sección de shows relacionados ---
                if (relatedShows != null && relatedShows.isNotEmpty) ...[
                  const Divider(),
                  const Text('Relacionados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: relatedShows.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final r = relatedShows[i];
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
                                    apiService: widget.apiService,
                                    countryCode: widget.countryCode,
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
                const Divider(),
                const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ordenar comentarios:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _sort,
                      items: _sortLabels.keys.map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(_sortLabels[key]!),
                      )).toList(),
                      onChanged: _changeSort,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<dynamic>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error al cargar comentarios', style: TextStyle(color: Colors.red));
                    }
                    final comments = snapshot.data;
                    if (comments == null || comments.isEmpty) {
                      return const Text('No hay comentarios para este show.');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final c = comments[i];
                        final user = c['user']?['username'] ?? 'Anónimo';
                        final date = c['created_at']?.substring(0, 10) ?? '';
                        final text = c['comment'] ?? '';
                        return ListTile(
                          title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(text),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    // Usa url_launcher si lo deseas, aquí solo muestra un dialogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir enlace'),
        content: Text(url),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}
