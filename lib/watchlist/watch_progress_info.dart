import 'package:flutter/material.dart';
import 'package:watching/watchlist/progress_bar.dart';
import 'package:watching/watchlist/episode_info_button.dart';
import 'package:watching/api_service.dart';

class WatchProgressInfo extends StatefulWidget {
  final String? traktId;
  final String title;
  final ApiService apiService;

  const WatchProgressInfo({Key? key, required this.traktId, required this.title, required this.apiService}) : super(key: key);

  @override
  State<WatchProgressInfo> createState() => _WatchProgressInfoState();
}

class _WatchProgressInfoState extends State<WatchProgressInfo> {
  Map<String, dynamic>? progress;
  bool loading = false;
  bool error = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.traktId == null) return;
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final prog = await widget.apiService.getShowWatchedProgress(id: widget.traktId!);
      if (!mounted || _disposed) return;
      setState(() {
        progress = prog;
        loading = false;
      });
    } catch (e) {
      if (!mounted || _disposed) return;
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
    final TextStyle episodeStyle = Theme.of(context).textTheme.bodyMedium!;

    if (widget.traktId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
        ],
      );
    }
    if (loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 8),
        ],
      );
    }
    if (error || progress == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: titleStyle),
          const SizedBox(height: 8),
          Text('Error al cargar progreso', style: TextStyle(color: Colors.red)),
        ],
      );
    }
    final episodesWatched = progress!['completed'] ?? 0;
    final totalEpisodes = progress!['aired'] ?? 1;
    final nextEpisode = progress!['next_episode'];
    final percent = totalEpisodes > 0 ? (episodesWatched / totalEpisodes).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: titleStyle),
        if (nextEpisode != null) ...[
          const SizedBox(height: 6),
          Text(
            'T${nextEpisode['season']}E${nextEpisode['number']} - ${nextEpisode['title']}',
            style: episodeStyle.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          ProgressBar(percent: percent, watched: episodesWatched, total: totalEpisodes),
          const SizedBox(height: 6),
          EpisodeInfoButton(
            traktId: widget.traktId,
            season: nextEpisode['season'],
            episode: nextEpisode['number'],
            apiService: widget.apiService,
          ),
        ],
      ],
    );
  }
}
