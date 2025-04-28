import 'package:flutter/material.dart';
import '../api_service.dart';
import 'cast_guest.dart';
import '../youtube_player_dialog.dart';
import 'header.dart';
import 'videos.dart';
import 'cast.dart';
import 'related.dart';
import 'comments.dart';

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
          widget.apiService.getShowPeople(widget.showId),
          widget.apiService.getRelatedShows(widget.showId),
          widget.apiService.getShowVideos(widget.showId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          final results = snapshot.data;
          if (results == null || results.length < 6) {
            return const Center(child: Text('No se encontraron datos.'));
          }
          final show = results[0] as Map<String, dynamic>?;
          final translations = results[1] as List<dynamic>?;
          final certifications = results[2] as List<dynamic>?;
          final people = results[3] as Map<String, dynamic>?;
          final relatedShows = results[4] as List<dynamic>?;
          final videos = results[5] as List<dynamic>?;
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
                ShowDetailHeader(
                  show: show,
                  translation: translation,
                  showOriginal: _showOriginal,
                  onToggleOriginal: (val) => setState(() => _showOriginal = val),
                  originalTitle: originalTitle,
                  originalOverview: originalOverview,
                  originalTagline: originalTagline,
                  certifications: certifications,
                  countryCode: widget.countryCode,
                  apiService: widget.apiService,
                  showId: widget.showId,
                ),
                ShowDetailVideos(videos: videos),
                ShowDetailCast(people: people, showId: widget.showId, apiService: widget.apiService),
                ShowDetailRelated(relatedShows: relatedShows, apiService: widget.apiService, countryCode: widget.countryCode),
                ShowDetailComments(
                  commentsFuture: _commentsFuture,
                  sort: _sort,
                  sortLabels: _sortLabels,
                  onChangeSort: _changeSort,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
