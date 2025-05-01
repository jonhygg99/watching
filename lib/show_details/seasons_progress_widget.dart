import 'package:flutter/material.dart';
import '../api_service.dart';
import '../watchlist/watch_progress_info.dart';
import '../watchlist/progress_bar.dart';

class SeasonsProgressWidget extends StatefulWidget {
  final String showId;
  final VoidCallback? onProgressChanged;
  const SeasonsProgressWidget({Key? key, required this.showId, this.onProgressChanged}) : super(key: key);

  @override
  State<SeasonsProgressWidget> createState() => _SeasonsProgressWidgetState();
}

class _SeasonsProgressWidgetState extends State<SeasonsProgressWidget> {
  List<dynamic>? seasons;
  Map<String, dynamic>? progress;
  bool loading = true;
  bool marking = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => loading = true);
    try {
      final s = await apiService.getSeasons(widget.showId);
      final p = await apiService.getShowWatchedProgress(id: widget.showId);

      setState(() {
        seasons = s;
        progress = p;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      // Manejo de error: opcional mostrar snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (seasons == null || progress == null) {
      return const SizedBox();
    }
    final progressSeasons = Map.fromEntries(
      (progress!["seasons"] as List).map((s) => MapEntry(s["number"], s)),
    );

    // Filtrar temporadas: ocultar la 0 y la última si tienen 0 episodios
    final filteredSeasons = List<Map<String, dynamic>>.from(seasons!)
      ..removeWhere((season) {
        final number = season["number"];
        final episodeCount = season["episode_count"] ?? 0;
        final isFirst = number == 0;
        final isLast = number == (seasons!.isNotEmpty ? seasons!.map((s) => s["number"] as int).reduce((a, b) => a > b ? a : b) : -1);
        return (isFirst || isLast) && episodeCount == 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Temporadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...filteredSeasons.map<Widget>((season) {
          final number = season["number"];
          final episodeCount = season["episode_count"] ?? 0;
          final seasonProgress = progressSeasons[number] ?? {};
          final completed = seasonProgress["completed"] ?? 0;
          final aired = seasonProgress["aired"] ?? episodeCount;
          final isComplete = completed == aired && aired > 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: isComplete
                        ? Colors.green
                        : (markingColors[number] ?? Colors.grey),
                  ),
                  onPressed: isComplete
                      ? null
                      : () => _markSeasonAsWatched(number, episodeCount),
                  tooltip: isComplete ? 'Completada' : 'Marcar temporada como vista',
                ),
                Text('Temporada $number', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: ProgressBar(
                    percent: (aired == 0 || completed < 0 || aired < 0)
                        ? 0.0
                        : (completed / aired).clamp(0.0, 1.0),
                    watched: completed,
                    total: aired,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  int? seasonMarkingNumber;
  Map<int, Color> markingColors = {};

  Future<void> _markSeasonAsWatched(int seasonNumber, int episodeCount) async {
    setState(() {
      markingColors[seasonNumber] = Colors.blue;
    });
    try {
      await apiService.addToWatchHistory(
        shows: [
          {
            "ids": int.tryParse(widget.showId) != null
                ? {"trakt": int.parse(widget.showId)}
                : {"slug": widget.showId},
            "seasons": [
              {
                "number": seasonNumber,
              }
            ]
          }
        ]
      );
      await _fetchData();
      if (widget.onProgressChanged != null) widget.onProgressChanged!();
      setState(() {
        markingColors[seasonNumber] = Colors.grey;
      });
    } catch (e) {
      setState(() {
        markingColors[seasonNumber] = Colors.red;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        markingColors[seasonNumber] = Colors.grey;
      });
    }
  }
}