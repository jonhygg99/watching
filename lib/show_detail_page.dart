import 'package:flutter/material.dart';
import 'api_service.dart';

class ShowDetailPage extends StatelessWidget {
  final String showId;
  final ApiService apiService;

  const ShowDetailPage({super.key, required this.showId, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Show')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: apiService.getShowById(showId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          final show = snapshot.data;
          if (show == null) {
            return const Center(child: Text('No se encontraron datos.'));
          }
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
                Text(show['title'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (show['tagline'] != null && show['tagline'].toString().isNotEmpty)
                  Text(show['tagline'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                if (show['overview'] != null)
                  Text(show['overview'], style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (show['year'] != null) Chip(label: Text('Año: \\${show['year']}')),
                    if (show['runtime'] != null) Chip(label: Text('Duración: \\${show['runtime']} min')),
                    if (show['status'] != null) Chip(label: Text('Estado: \\${show['status']}')),
                    if (show['network'] != null) Chip(label: Text('Canal: \\${show['network']}')),
                    if (show['rating'] != null) Chip(label: Text('Rating: \\${show['rating']}')),
                    if (show['genres'] != null && show['genres'] is List && show['genres'].isNotEmpty)
                      Chip(label: Text('Géneros: \\${(show['genres'] as List).join(', ')}')),
                  ],
                ),
                const SizedBox(height: 14),
                if (show['homepage'] != null && show['homepage'].toString().isNotEmpty)
                  TextButton(
                    onPressed: () => _launchUrl(context, show['homepage']),
                    child: const Text('Página oficial', style: TextStyle(fontSize: 16)),
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
