import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_service.dart';
import '../app_providers.dart';
import 'seasons_progress_widget.dart';
import 'header.dart';
import 'videos.dart';
import 'cast.dart';
import 'related.dart';
import 'comments.dart';

/// Displays detailed information about a TV show, including header, seasons, videos, cast, related shows, and comments.
/// Uses Riverpod for dependency injection and state management.
class ShowDetailPage extends ConsumerStatefulWidget {
  final String showId;
  const ShowDetailPage({super.key, required this.showId});

  @override
  ConsumerState<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends ConsumerState<ShowDetailPage> {
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

  late ApiService _apiService;
  late String _countryCode;

  @override
  void initState() {
    super.initState();
    // _apiService and _countryCode are set in build via ref.watch
    // _commentsFuture is set in build as well for correct provider usage
  }

  void _changeSort(String? value) {
    if (value == null || value == _sort) return;
    setState(() {
      _sort = value;
      _commentsFuture = _apiService.getShowComments(widget.showId, sort: _sort);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Riverpod providers for dependencies
    _apiService = ref.watch(apiServiceProvider);
    _countryCode = ref.watch(countryCodeProvider);
    _commentsFuture = _apiService.getShowComments(widget.showId, sort: _sort);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Show')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _apiService.getShowById(widget.showId),
          _apiService.getShowTranslations(
            widget.showId,
            _countryCode.substring(0, 2).toLowerCase(),
          ),
          _apiService.getShowCertifications(widget.showId),
          _apiService.getShowPeople(widget.showId),
          _apiService.getRelatedShows(widget.showId),
          _apiService.getShowVideos(widget.showId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: \\${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
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
              (t) =>
                  t['language']?.toString().toLowerCase() ==
                  _countryCode.substring(0, 2).toLowerCase(),
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
                  onToggleOriginal:
                      (val) => setState(() => _showOriginal = val),
                  originalTitle: originalTitle,
                  originalOverview: originalOverview,
                  originalTagline: originalTagline,
                  certifications: certifications,
                  countryCode: _countryCode,
                  apiService: _apiService,
                  showId: widget.showId,
                ),
                SeasonsProgressWidget(showId: widget.showId),
                ShowDetailVideos(videos: videos),
                ShowDetailCast(
                  people: people,
                  showId: widget.showId,
                  apiService: _apiService,
                ),
                ShowDetailRelated(
                  relatedShows: relatedShows,
                  apiService: _apiService,
                  countryCode: _countryCode,
                ),
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
